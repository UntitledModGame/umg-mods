

lp.metaprogression = {}


local SEP_PATTERN = "%:"


local function fromNamespaced(nsStr)
    --  "modname:str"  --->  "modname", "str"
    local s,_ = nsStr:find(SEP_PATTERN)
    if s then
        return nsStr:sub(1,s-1), nsStr:sub(s+1)
    end
    umg.melt("Invalid namespace-str, needs colon: ", nsStr)
end



local UNLOCK_STORAGE = {
    folder = "unlocks/",
    cache = {}
}
local SEEN_STORAGE = {
    folder = "unlocks/",
    cache = {}
}


---@param storage table
---@param namespace string
local function getFname(storage, namespace)
    return storage.folder .. namespace .. ".json"
end

---@param storage table
---@param namespace string
local function getSaveTable(storage, namespace)
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
    local namespace, str = fromNamespaced(name)
    local saveTabl = getSaveTable(storage, namespace)
    saveTabl[str] = value
    local data = json.encode(saveTabl)
    local fsys = server.getSaveFilesystem()
    return fsys:write(getFname(storage, namespace), data)
end



function lp.metaprogression.isUnlocked(name)
    local ns, str = fromNamespaced(name)
    return getSaveTable(UNLOCK_STORAGE, ns)[str]
end

function lp.metaprogression.unlock(name)
    setValue(UNLOCK_STORAGE, name, true)
end



function lp.metaprogression.isSeen(name)
    local ns, str = fromNamespaced(name)
    return getSaveTable(SEEN_STORAGE, ns)[str]
end

function lp.metaprogression.see(name)
    setValue(SEEN_STORAGE, name, true)
end



local STAT_FILE = "metaprogression.stats.json"


local statTable = {}
do
    local dat = server.getSaveFilesystem()
        :read(STAT_FILE)
    if dat then
        statTable = json.decode(dat)
    end
end

function lp.metaprogression.setStat(key, val)
    statTable[key] = val
end
function lp.metaprogression.getStat(key, val)
    return statTable[key]
end
function lp.metaprogression.defineStat(key, startingValue)
    statTable[key] = statTable[key] or startingValue
end

umg.on("@quit", function()
    local fsys = server.getSaveFilesystem()
    fsys:write(STAT_FILE, json.encode(statTable))
end)


--[[

lp.metaprogression.tryUnlock(plot, selfTeamId)

local plotData = lp.metaprogression.getPlotData(plot)
plotData.totalCounts["item"]
plotData.counts["item"] -- where `lootplotTeam == selfTeamId`

-- Call this in lp.main
lp.metaprogression.unlockEverything()

]]

