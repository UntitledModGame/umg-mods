---@param targetFunc function
---@param ent lootplot.ItemEntity
---@param targets objects.Array
---@param conversion? "ITEM"|"SLOT"
local function activateTargets(targetFunc, ent, targets, conversion)
    lp.Bufferer()
        :addAll(targets)
        :to(conversion)
        :execute(function(ppos, targetEnt)
            targetFunc(ent, ppos, targetEnt)
        end)
end

local VALIDS = {SLOT=true, ITEM=true}

umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        ---@cast ent lootplot.ItemEntity
        local targets = lp.targets.getTargets(ent)

        if targets then
            local to = ent.targetType
            if (not VALIDS[to]) then
                error("Invalid targetType: " .. tostring(to))
            end 
            activateTargets(ent.activateTargets, ent, targets, to)
        end
    end
end)
