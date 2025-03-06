

lp.metaprogression = {}

umg.definePacket("lootplot.metaprogression:unlock", {
    typelist = {"string", "boolean"}
})

umg.definePacket("lootplot.metaprogression:allUnlockData", {
    -- pckr table
    typelist = {"string"}
})



local SEP_PATTERN = "%:"


local function fromNamespaced(nsStr)
    --  "modname:str"  --->  "modname", "str"
    local s,_ = nsStr:find(SEP_PATTERN)
    if s then
        return nsStr:sub(1,s-1), nsStr:sub(s+1)
    end

    -- "my_string" -- INVALID! Needs to be prefixed by mod
    -- "my_mod:my_string" <--- valid.
    umg.melt("Invalid namespaced-string. Needs colon: ", nsStr)
end



local UNLOCK_STORAGE = {
    folder = "unlocks/",
    cache = {}
}

local CLIENT_UNLOCK_CACHE = {--[[
    hash of current unlocks. Keyed by string
    [unlockString] -> bool
]]}



local function assertServer()
    assert(server, "Can only be called on server-side!")
end


---@param storage table
---@param namespace string
local function getFname(storage, namespace)
    return storage.folder .. namespace .. ".json"
end

---@param storage table
---@param namespace string
local function getSaveTable(storage, namespace)
    assertServer()
    if storage.cache[namespace] then
        return storage.cache
    end
    local fsys = server.getSaveFilesystem()
    local data = fsys:read(getFname(storage, namespace))
    if data then
        return json.decode(data)
    end
    return {}
end



---@param storage table
---@param name string
---@param value boolean
local function setValue(storage, name, value)
    assertServer()
    local namespace, str = fromNamespaced(name)
    local saveTabl = getSaveTable(storage, namespace)
    if saveTabl[str] == value then
        return false
    end
    saveTabl[str] = value
    local data = json.encode(saveTabl)
    local fsys = server.getSaveFilesystem()
    local fname = getFname(storage, namespace)
    local ok, err = fsys:write(fname, data)
    if ok then
        umg.log.debug("Saved file: ", fname, " with key-value: ", str, value)
        return true
    else
        umg.log.error(err)
    end
end


local isEntityTypeUnlockedTc = typecheck.assert("table")

function lp.metaprogression.isEntityTypeUnlocked(entityType)
    isEntityTypeUnlockedTc(entityType)
    if not entityType.unlock then
        return true -- its unlocked, because it doesnt have `unlock` component!
    end
    return lp.metaprogression.isUnlocked(entityType:getTypename())
end


--- Marks a string as "unlocked"
---@param name string Any kind of string value, representing an unlock. Generally, this will be an entity-type name. MUST BE PREFIXED BY THE MOD-NAME!!!  Eg: "my_mod:item"
function lp.metaprogression.isUnlocked(name)
    if server then
        local ns, str = fromNamespaced(name)
        return getSaveTable(UNLOCK_STORAGE, ns)[str]
    else
        return CLIENT_UNLOCK_CACHE[name]
    end
end


--- Marks a string as "unlocked"
---@param name string Any kind of string value, representing an unlock. Generally, this will be an entity-type name. MUST BE PREFIXED BY THE MOD-NAME!!!  Eg: "my_mod:item"
function lp.metaprogression.unlock(name)
    assertServer()
    local saved = setValue(UNLOCK_STORAGE, name, true)
    if saved then
        server.broadcast("lootplot.metaprogression:unlock", name, true)
    end
end








-- NOTE: we can't use `/` here, because that's an invalid character
local STAT_FILE = "lootplot.metaprogression.stats.json"


local statDefaults = {--[[
    [statKey] -> defaultValue
]]}


local statTable = {}

local statTableOutOfDate = true

if server then
    local dat = server.getSaveFilesystem()
        :read(STAT_FILE)
    if dat then
        statTable = json.decode(dat)
    end
end




local setStatTc = typecheck.assert("string", "number")
function lp.metaprogression.setStat(key, val)
    setStatTc(key, val)
    assert(server, "?")
    assert(statDefaults[key], "Invalid stat: " .. key)
    if statTable[key] ~= val then
        statTableOutOfDate = true
        statTable[key] = val
    end
end



---@param key any
---@return number
function lp.metaprogression.getStat(key)
    assert(statDefaults[key], "Invalid stat: " .. key)
    if client then
        return statTable[key] or statDefaults[key]
    else
        -- stat should always exist on server; else bug.
        assert(statTable[key])
        return statTable[key]
    end
end



local defStatTc = typecheck.assert("string", "number")
function lp.metaprogression.defineStat(key, defaultValue)
    defStatTc(key, defaultValue)
    assert(umg.isNamespaced(key))
    statDefaults[key] = defaultValue
    if server and (not statTable[key]) then
        lp.metaprogression.setStat(key, defaultValue)
    end
end



umg.definePacket("lootplot.metaprogression:syncStats", {
    typelist = {"string"}
})



if server then


---If no clientId is specified, syncs to ALL players
---@param clientId? string
local function syncStatsToClient(clientId)
    assert(server,"?")
    local data = json.encode(statTable)
    if clientId then
        server.unicast(clientId, "lootplot.metaprogression:syncStats", data)
    else
        server.broadcast("lootplot.metaprogression:syncStats", data)
    end
end


local function trySaveStatTable()
    if statTableOutOfDate then
        local fsys = server.getSaveFilesystem()
        fsys:write(STAT_FILE, json.encode(statTable))
        syncStatsToClient()
        statTableOutOfDate = false
    end
end



local NUM_SKIP_TICKS = 50
local ct = 1
umg.on("@tick", function()
    ct = ct + 1
    if ct % NUM_SKIP_TICKS == 0 then
        trySaveStatTable()
    end
end)

umg.on("@playerJoin", function(clientId)
    syncStatsToClient(clientId)
end)

end










if server then

---@param storage table
local function createStorage(storage)
    local fsys = server.getSaveFilesystem()
    fsys:createDirectory(storage.folder)
end

createStorage(UNLOCK_STORAGE)

umg.on("@playerJoin",function(clientId)
    server.unicast(clientId, "lootplot.metaprogression:allUnlockData", umg.serialize(UNLOCK_STORAGE.cache))
end)

end




if client then

client.on("lootplot.metaprogression:unlock", function(unlock, bool)
    CLIENT_UNLOCK_CACHE[unlock] = bool
end)

client.on("lootplot.metaprogression:allUnlockData", function(unlockData)
    local tabl, er = umg.deserialize(unlockData)
    if not tabl then
        umg.log.error("Couldnt deser data: ", er)
    end
    CLIENT_UNLOCK_CACHE = tabl
end)

client.on("lootplot.metaprogression:syncStats", function(jsonData)
    local tabl = json.decode(jsonData)
    statTable = tabl
end)

end

