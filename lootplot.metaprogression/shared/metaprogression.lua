

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

end

