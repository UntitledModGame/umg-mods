
require("shared.events_questions")

local util = {}

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end


local function tryConvert(targeterEnt, ppos)
    if targeterEnt.targetType == "ITEM" then
        local item = lp.posToItem(ppos)
        return (not not item), item
    elseif targeterEnt.targetType == "SLOT" then
        local slot = lp.posToSlot(ppos)
        return (not not slot), slot
    elseif targeterEnt.targetType == "NO_ITEM" then
        return lp.posToSlot(ppos) and (not lp.posToItem(ppos))
    elseif targeterEnt.targetType == "NO_SLOT" then
        return not lp.posToSlot(ppos)
    end
    return false
end


local function checkFilter(targeterEnt, ppos, val)
    if targeterEnt.targetFilter then
        return targeterEnt.targetFilter(targeterEnt, ppos, val)
    end
    return umg.ask("lootplot.targets:canTarget", targeterEnt, ppos, val)
end

function util.canTarget(targeterEnt, ppos)
    local ok,val = tryConvert(targeterEnt, ppos)
    if targeterEnt.targetType then
        if ok then
            return checkFilter(targeterEnt, ppos, val)
        end
        return false -- cannot target empty!
    else
        return checkFilter(targeterEnt, ppos, nil)
    end
end



return util
