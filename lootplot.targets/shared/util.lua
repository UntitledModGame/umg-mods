local util = {}

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end


local function tryConvert(targeterEnt, ppos)
    if targeterEnt.targetType == "ITEM" then
        return true, lp.posToItem(ppos)
    elseif targeterEnt.targetType == "SLOT" then
        return true, lp.posToSlot(ppos)
    elseif targeterEnt.targetType == "NO_ITEM" then
        return not lp.posToItem(ppos)
    elseif targeterEnt.targetType == "NO_SLOT" then
        return not lp.posToSlot(ppos)
    end
    return false
end


local function checkFilter(targeterEnt, ppos, val)
    if targeterEnt.targetFilter then
        return targeterEnt.targetFilter(targeterEnt, ppos, val)
    end
    return true
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
