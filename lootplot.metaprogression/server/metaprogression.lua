

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
    if server then
        local ns, str = fromNamespaced(name)
        return getSaveTable(UNLOCK_STORAGE, ns)[str]
    else
        umg.melt("nyi")
    end
end

function lp.metaprogression.unlock(name)
    setValue(UNLOCK_STORAGE, name, true)
end




local STAT_FILE = "metaprogression.stats.json"


local validStats = {}

-- DEFAULT STATS:
local statTable = {
    WINS = 0,
    LOSSES = 0,
    TOTAL_POINTS_EARNED = 0,
    TOTAL_MONEY_EARNED = 0,
}

local statTableOutOfDate = true
do
    local dat = server.getSaveFilesystem()
        :read(STAT_FILE)
    if dat then
        statTable = json.decode(dat)
    end
end

function lp.metaprogression.setStat(key, val)
    assert(validStats[key], "Invalid stat: " .. key)
    if statTable[key] ~= val then
        statTableOutOfDate = true
        statTable[key] = val
    end
end
function lp.metaprogression.getStat(key)
    assert(validStats[key], "Invalid stat: " .. key)
    return statTable[key]
end

local function trySaveStatTable()
    if statTableOutOfDate then
        local fsys = server.getSaveFilesystem()
        fsys:write(STAT_FILE, json.encode(statTable))
        statTableOutOfDate = false
    end
end


---@param plot lootplot.Plot
function lp.metaprogression.winAndUnlockItems(plot)
    --[[
    unlock component:

    defineItem("qux", {
        ...
        unlock = {
            requiredItems = {"foo", "bar"},
            description = "Win using foo and bar items!"
        }
    })

    ^^^ if the player wins with `foo` and `bar` items on the plot,
    then `qux` is unlocked.
    ]]
    assert(server, "?")
    local seen = {}
    local unlockBuffer = objects.Array()
    for _name, etype in pairs(server.entities) do
        if not seen[etype] then
            seen[etype]=true
        end
        if seen.unlock then
            unlockBuffer:add(etype)
        end
    end

    local itemCounts = {}
    plot:foreachItem(function(item, ppos)
        local n = item:type()
        itemCounts[n]=(itemCounts[n] or 0) + 1
    end)

    unlockBuffer:map(function(etype)
        local n = etype:getTypename()
        local unlock = etype.unlock
        if unlock.requiredItems then
            for _, itemType in ipairs(unlock.requiredItems) do
                if (itemCounts[itemType] or 0) <= 0 then
                    return -- failed!
                end
            end
            -- else, we unlock item:
            lp.metaprogression.unlock(n)
        end
    end)
end


local NUM_SKIP_TICKS = 50
local ct = 1
umg.on("@tick", function()
    ct = ct + 1
    if ct % NUM_SKIP_TICKS == 0 then
        trySaveStatTable()
    end
end)

