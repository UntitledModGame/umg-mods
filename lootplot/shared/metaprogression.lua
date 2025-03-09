

local metaprogression = {}

umg.definePacket("lootplot:metaprogression.setFlag", {
    typelist = {"string", "boolean"}
})

umg.definePacket("lootplot:metaprogression.syncFlags", {
    -- pckr table
    typelist = {"string"}
})



local SEP_PATTERN = "%:"

local function assertNamespaced(nsStr)
    local s,_ = nsStr:find(SEP_PATTERN)
    if not s then
        -- eh this doesnt actually check the mod, but its "good enough"
        umg.melt("string must be namespaced: " .. tostring(nsStr))
    end
end



local FLAG_FILE = "lootplot.metaprogression.flags.json"

local flagTable = {--[[
    table of flag-values. Keyed by string
    [flag] -> bool
]]}
local flagTableOutOfDate = false

if server then
    local dat = server.getSaveFilesystem()
        :read(FLAG_FILE)
    if dat then
        flagTable = json.decode(dat)
    end
end




local function assertServer()
    assert(server, "Can only be called on server-side!")
end



local VALID_FLAGS = {--[[
    [flag] -> boolean
]]}


---Defines a flag
---@param flag string
function metaprogression.defineFlag(flag)
    VALID_FLAGS[flag] = true
end

--- Gets a boolean flag value
---@param flag string Any kind of string value, representing an unlock. Generally, this will be an entity-type name. MUST BE PREFIXED BY THE MOD-NAME!!!  Eg: "my_mod:item"
---@return boolean
function metaprogression.getFlag(flag)
    if not (VALID_FLAGS[flag]) then
        umg.melt("Invalid flag: " .. tostring(flag))
    end
    if server then
        return flagTable[flag]
    else
        return flagTable[flag]
    end
end


--- Sets a bool value for a flag
---@param flag string Any kind of string value, representing an unlock. Generally, this will be an entity-type name. MUST BE PREFIXED BY THE MOD-NAME!!!  Eg: "my_mod:item"
---@param val boolean 
function metaprogression.setFlag(flag, val)
    assertServer()
    assertNamespaced(flag)

    if not (VALID_FLAGS[flag]) then
        umg.melt("Invalid flag: " .. tostring(flag))
    end
    if flagTable[flag] == val then
        umg.log.info("setValue delta-compressed: ", flag, val)
        return false
    end
    flagTable[flag] = val
    local data = json.encode(flagTable)
    local fsys = server.getSaveFilesystem()
    local ok, err = fsys:write(FLAG_FILE, data)

    if ok then
        server.broadcast("lootplot:metaprogression.setFlag", flag, val)
    else
        umg.log.error("Failed to set flag: ", err)
    end
end








-- NOTE: we can't use proper namespacing with `:` here, because it's invalid file character
-- (fsys:write was failing lul)
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
function metaprogression.setStat(key, val)
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
function metaprogression.getStat(key)
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

---@param key string
---@param defaultValue number
function metaprogression.defineStat(key, defaultValue)
    defStatTc(key, defaultValue)
    assert(umg.isNamespaced(key))
    statDefaults[key] = defaultValue
    if server and (not statTable[key]) then
        metaprogression.setStat(key, defaultValue)
    end
end



umg.definePacket("lootplot:metaprogression.syncStats", {
    typelist = {"string"}
})



if server then


---If no clientId is specified, syncs to ALL players
---@param clientId? string
local function syncStatsToClient(clientId)
    assert(server,"?")
    local data = json.encode(statTable)
    if clientId then
        server.unicast(clientId, "lootplot:metaprogression.syncStats", data)
    else
        server.broadcast("lootplot:metaprogression.syncStats", data)
    end
end


---If no clientId is specified, syncs to ALL players
---@param clientId? string
local function syncFlagsToClient(clientId)
    assert(server,"?")
    local data = json.encode(flagTable)
    if clientId then
        server.unicast(clientId, "lootplot:metaprogression.syncFlags", data)
    else
        server.broadcast("lootplot:metaprogression.syncFlags", data)
    end
end





local function trySaveTables()
    if statTableOutOfDate then
        local fsys = server.getSaveFilesystem()
        fsys:write(STAT_FILE, json.encode(statTable))
        syncStatsToClient()
        statTableOutOfDate = false
    end

    if flagTableOutOfDate then
        local fsys = server.getSaveFilesystem()
        fsys:write(FLAG_FILE, json.encode(flagTable))
        syncFlagsToClient()
        flagTableOutOfDate = false
    end
end



local NUM_SKIP_TICKS = 50
local ct = 1
umg.on("@tick", function()
    ct = ct + 1
    if ct % NUM_SKIP_TICKS == 0 then
        trySaveTables()
    end
end)



umg.on("@playerJoin", function(clientId)
    syncStatsToClient(clientId)
    syncFlagsToClient(clientId)
end)

end






if client then

client.on("lootplot:metaprogression.setFlag", function(flag, bool)
    flagTable[flag] = bool
end)

client.on("lootplot:metaprogression.syncFlags", function(flagData)
    local tabl = json.decode(flagData)
    flagTable = tabl
end)

client.on("lootplot:metaprogression.syncStats", function(jsonData)
    local tabl = json.decode(jsonData)
    statTable = tabl
end)

end


return metaprogression
