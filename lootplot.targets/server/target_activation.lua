
local util = require("shared.util")



---@param ent lootplot.ItemEntity
---@param targets objects.Array
---@param conversion? "ITEM"|"SLOT"
local function activateTargets(ent, targets, conversion)
    local target = ent.target
    lp.Bufferer()
        :addAll(targets)
        :to(conversion)
        :filter(function(ppos)
            -- this is a bit janky, but oh well
            if umg.exists(ent)then
                return util.canTarget(ent, ppos)
            end
            return false
        end)
        :execute(function(ppos, targetEnt)
            if umg.exists(ent) then
                if target.activate then
                    target.activate(ent, ppos, targetEnt)
                end
                umg.call("lootplot.targets:targetActivated", ent, ppos, targetEnt)
            end
        end)
end

local VALIDS = {SLOT=true, ITEM=true, NO_ITEM=true, NO_SLOT=true}

umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        ---@cast ent lootplot.ItemEntity
        local targets = lp.targets.getTargets(ent)

        if targets then
            local to = ent.target and ent.target.type
            if (to and (not VALIDS[to])) then
                error("Invalid target.type: " .. tostring(to))
            end 
            activateTargets(ent, targets, to)
        end
    end
end)
