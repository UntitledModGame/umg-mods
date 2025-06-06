
require("shared.events_questions")

local util = {}

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end


local function checkFilter(targeterEnt, compTable, ppos, val)
    if compTable.filter then
        return compTable.filter(targeterEnt, ppos, val)
    end
    return true -- no filter => always OK.
end

function util.canTarget(targeterEnt, ppos)
    local target = targeterEnt.target
    assert(target, "Not a target entity?")
    local targetType = target.type
    local ok,val = lp.tryConvert(ppos, targetType)
    if target.type then
        if ok then
            return checkFilter(targeterEnt, target, ppos, val)
        end
        return false -- cannot target empty!
    else
        return checkFilter(targeterEnt, target, ppos, nil)
    end
end



function util.canListen(listenerEnt, ppos)
    local listen = listenerEnt.listen
    assert(listen, "Not a listen entity?")
    local targEnt = lp.tryConvert(ppos, listen.type)
    if targEnt then
        return checkFilter(listenerEnt, listen, ppos, targEnt)
    else
        return false
    end
end




--- returns deterministic hash of coords
---@param coords {[1]:integer,[2]:integer}[]
---@return string
function util.hashCoords(coords)
    local result = {}
    local sortedCoords = table.deepCopy(coords)
    table.sort(sortedCoords, function(a, b)
        if a[1] == b[1] then
            return a[2] < b[2]
        else
            return a[1] < b[1]
        end
    end)

    for _, v in ipairs(sortedCoords) do
        result[#result+1] = util.coordsToString(v[1], v[2])
    end

    return table.concat(result)
end



---@param x integer
---@param y integer
function util.coordsToString(x, y)
    x = x % 4294967296
    y = y % 4294967296
    return string.char(
        x % 256,
        (x / 256) % 256,
        (x / 65536) % 256,
        (x / 16777216) % 256,
        y % 256,
        (y / 256) % 256,
        (y / 65536) % 256,
        (y / 16777216) % 256
    )
end



return util
