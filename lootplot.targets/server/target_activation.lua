
local util = require("shared.util")



---@param ent lootplot.ItemEntity
---@param targets objects.Array
---@param conversion? "ITEM"|"SLOT"
local function activateTargets(ent, targets, conversion)
    lp.Bufferer()
        :addAll(targets)
        :to(conversion)
        :filter(util.canTarget)
        :execute(function(ppos, targetEnt)
            if ent.targetActivate then
                ent:targetActivate(ppos, targetEnt)
            end
            umg.call("lootplot.targets:targetActivated", ent, ppos, targetEnt)
        end)
end

local VALIDS = {SLOT=true, ITEM=true, NO_ITEM=true, NO_SLOT=true}

umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        ---@cast ent lootplot.ItemEntity
        local targets = lp.targets.getTargets(ent)

        if targets then
            local to = ent.targetType
            if (to and (not VALIDS[to])) then
                error("Invalid targetType: " .. tostring(to))
            end 
            activateTargets(ent, targets, to)
        end
    end
end)
