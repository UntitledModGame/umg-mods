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

umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        ---@cast ent lootplot.ItemEntity
        local targets = lp.targets.getTargets(ent)

        if targets then
            if ent.activateTargetItems then
                activateTargets(ent.activateTargetItems, ent, targets, "ITEM")
            end

            if ent.activateTargetPositions then
                activateTargets(ent.activateTargetPositions, ent, targets, nil)
            end

            if ent.activateTargetSlots then
                activateTargets(ent.activateTargetSlots, ent, targets, "SLOT")
            end
        end
    end
end)
