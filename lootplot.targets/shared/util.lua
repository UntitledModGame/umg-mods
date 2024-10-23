
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




return util
