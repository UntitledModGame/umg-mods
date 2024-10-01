

local util = {}

---comment
---@param ppos lootplot.PPos
---@param func fun(ent:Entity)
function util.forNeighborItems(ppos, func)
    -- loops neighbor items in a KING shape
    for dx=-1,1 do
        for dy=-1,1 do
            if (dx ~= 0) or (dy ~= 0) then
                local pos2 = ppos:move(dx,dy)
                if pos2 then
                    local item = lp.posToItem(pos2)
                    if item then
                        func(item)
                    end
                end
            end
        end
    end
end



function util.canCombine(upgradeEnt, deleteEnt)
    if (upgradeEnt:type() == deleteEnt:type()) and (upgradeEnt.tier == deleteEnt.tier) then
        return true
    end
    return false
    --[[
    TODO: allow for more exotic matches here?
    (q-bus?)
    eg iron-sword + iron-bar = UPGRADE
    ]]
end


return util
