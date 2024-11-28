
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
    local itemEnt = lp.posToItem(ppos)
    if itemEnt then
        return checkFilter(listenerEnt, listen, ppos, itemEnt)
    else
        return false
    end
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
