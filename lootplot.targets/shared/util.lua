
require("shared.events_questions")

local util = {}

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end


local function checkFilter(targeterEnt, ppos, val)
    if targeterEnt.target.filter then
        return targeterEnt.target.filter(targeterEnt, ppos, val)
    end
    return umg.ask("lootplot.targets:canTarget", targeterEnt, ppos, val)
end

function util.canTarget(targeterEnt, ppos)
    local target = targeterEnt.target
    assert(target, "Not a target entity?")
    local targetType = target.type
    local ok,val = lp.tryConvert(ppos, targetType)
    if target.type then
        if ok then
            return checkFilter(targeterEnt, ppos, val)
        end
        return false -- cannot target empty!
    else
        return checkFilter(targeterEnt, ppos, nil)
    end
end



return util
