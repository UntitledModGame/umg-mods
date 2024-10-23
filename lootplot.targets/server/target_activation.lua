
local util = require("shared.util")



---@param ent lootplot.ItemEntity
---@param pposList objects.Array
---@param conversion? "ITEM"|"SLOT"
local function activateTargets(ent, pposList, conversion)
    local target = ent.target
    assert(target, "wot wot?")
    lp.Bufferer()
        :addAll(pposList)
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


umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        if ent.target then
            ---@cast ent lootplot.ItemEntity
            local pposList = lp.targets.getShapePositions(ent)
            if pposList then
                local to = ent.target.type
                if (to and (not lp.CONVERSIONS[to])) then
                    error("Invalid target.type: " .. tostring(to))
                end
                activateTargets(ent, pposList, to)
            end
        end
    end
end)
