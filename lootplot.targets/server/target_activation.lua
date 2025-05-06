
local util = require("shared.util")



---@param ent lootplot.ItemEntity
---@param pposList objects.Array
local function activateTargets(ent, pposList)
    local target = ent.target
    local conversion = target.type
    assert(target, "wot wot?")
    local bufferer = lp.Bufferer()
        :addAll(pposList)
        :to(conversion)

    local TARG_DELAY = 0.3
    if target.complexDelay then
        bufferer = bufferer:withEarlyDelay(TARG_DELAY)
    else
        bufferer = bufferer:withDelay(TARG_DELAY)
    end

    bufferer:filter(function(ppos)
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


umg.answer("lootplot:canActivateEntity", function(ent)
    if lp.isItemEntity(ent) and ent.target and ent.foodItem then
        if ent.target.activateWithNoValidTargets then
            -- activate even if there are no valid targets.
            return true
        end

        local t = lp.targets.getValidTargets(ent)
        return #t > 0 -- otherwise, only activate when we actually have targets
    end
    return true
end)



umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) and ent.target then
        ---@cast ent lootplot.ItemEntity
        local pposList = lp.targets.getTargets(ent)
        if pposList then
            local to = ent.target.type
            if (to and (not lp.CONVERSIONS[to])) then
                error("Invalid target.type: " .. tostring(to))
            end
            activateTargets(ent, pposList)
        end
    end
end)
