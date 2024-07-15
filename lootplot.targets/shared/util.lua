local util = {}

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end



local function tryGetVal(targeterEnt, ppos)
    if targeterEnt.targetType == "ITEM" then
        return lp.posToItem(ppos)
    elseif targeterEnt.targetType == "SLOT" then
        return lp.posToSlot(ppos)
    end
    return nil
end


local function checkFilter(targeterEnt, ppos, val)
    if targeterEnt.targetFilter then
        return targeterEnt.targetFilter(targeterEnt, ppos, val)
    end
    return true
end

function util.canTarget(targeterEnt, ppos)
    local val = tryGetVal(targeterEnt, ppos)
    if targeterEnt.targetType then
        if val then
            return checkFilter(targeterEnt, ppos, val)
        end
        return false -- cannot target empty!
    else
        return checkFilter(targeterEnt, ppos, nil)
    end
end



return util
