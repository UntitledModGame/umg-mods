
require("shared.metaprogression")


local STAT_FILE = "metaprogression.stats.json"


local validStats = {}

-- DEFAULT STATS:
local statTable = {
    WINS = 0,
    LOSSES = 0,
}

local statTableOutOfDate = true

if server then
    local dat = server.getSaveFilesystem()
        :read(STAT_FILE)
    if dat then
        statTable = json.decode(dat)
    end
end


function lp.metaprogression.setStat(key, val)
    assert(server, "?")
    assert(validStats[key], "Invalid stat: " .. key)
    if statTable[key] ~= val then
        statTableOutOfDate = true
        statTable[key] = val
    end
end



function lp.metaprogression.getStat(key)
    assert(server, "nyi client")
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



if server then

local NUM_SKIP_TICKS = 50
local ct = 1
umg.on("@tick", function()
    ct = ct + 1
    if ct % NUM_SKIP_TICKS == 0 then
        trySaveStatTable()
    end
end)

end

--[[

TODO:
Sync to client!

]]
