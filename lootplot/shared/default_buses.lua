

local calls = {
    COMBO = "lootplot:comboChanged",
    POINTS = "lootplot:pointsChanged",
    POINTS_BONUS = "lootplot:bonusChanged",
    POINTS_MULT = "lootplot:multChanged",
    MONEY = "lootplot:moneyChanged",
}

umg.on("lootplot:attributeChanged", function(attr, ent, delta, oldVal, newVal)
    if calls[attr] then
        umg.call(calls[attr], ent, delta, oldVal, newVal)
    end
end)



---@param ent Entity
---@param val number|function
---@param default number
---@return number
local function getVal(ent, val, default)
    if type(val) == "function" then
        return val(ent)
    elseif type(val) == "number" then
        return val
    end
    if umg.DEVELOPMENT_MODE then
        umg.melt("Error: invalid lootplotProperties return value for entity: " .. tostring(ent))
    else
        umg.log.error("[ERROR ERROR ERROR] Invalid lootplotProperties return value for entity: ", ent)
    end
    return default
end

local function getMult(ent, propTabl, prop)
    if propTabl.multipliers then
        local val = propTabl.multipliers[prop]
        if val then
            return getVal(ent, val, 1)
        end
    end
    return 1
end

local function getModifier(ent, propTabl, prop)
    if propTabl.modifiers then
        local val = propTabl.modifiers[prop]
        if val then
            return getVal(ent, val, 0)
        end
    end
    return 0
end


local function getClamp(ent, propTabl, prop)
    local min, max = -math.huge, math.huge

    if propTabl.maximums then
        local val = propTabl.maximums[prop]
        if val then
            max = getVal(ent, val, math.huge)
        end
    end

    if propTabl.minimums then
        local val = propTabl.minimums[prop]
        if val then
            min = getVal(ent, val, -math.huge)
        end
    end

    return min, max
end


-- LOOTPLOT PROPERTIES:
umg.answer("properties:getPropertyMultiplier", function(ent, prop)
    if ent.lootplotProperties then
        return getMult(ent, ent.lootplotProperties, prop)
    end
end)
umg.answer("properties:getPropertyModifier", function(ent, prop)
    if ent.lootplotProperties then
        return getModifier(ent, ent.lootplotProperties, prop)
    end
    return 0
end)
umg.answer("properties:getPropertyClamp", function(ent, prop)
    local min, max = -math.huge, math.huge
    if ent.lootplotProperties then
        min, max = getClamp(ent, ent.lootplotProperties, prop)
    end
    if prop == "maxActivations" then
        max = math.min(max, lp.MAX_ACTIVATIONS_LIMIT)
    end
    return min, max
end)



-- BUFFED PROPERTIES:
umg.answer("properties:getPropertyMultiplier", function(ent, prop)
    if ent.buffedProperties then
        return getMult(ent, ent.buffedProperties, prop)
    end
    return 1
end)
umg.answer("properties:getPropertyModifier", function(ent, prop)
    if ent.buffedProperties then
        return getModifier(ent, ent.buffedProperties, prop)
    end
    return 0
end)
umg.answer("properties:getPropertyClamp", function(ent, prop)
    local min, max = -math.huge, math.huge
    if ent.buffedProperties then
        return getClamp(ent, ent.buffedProperties, prop)
    end
    return min, max
end)




umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    local ppos = lp.getPos(ent)
    local team = lp.getPlayerTeam(clientId)
    if ppos then
        local plot = ppos:getPlot()
        if plot:isPipelineRunning() then
            return false
        end

        if team then
            return plot:isFogRevealed(ppos, team)
        end
    end
    return true
end)




umg.answer("lootplot:canAddItem", function(itemEnt, ppos)
    local slot = lp.posToSlot(ppos)
    if slot then
        -- button slots cant hold items!
        return not slot:hasComponent("buttonSlot")
    end
    return true -- else, its fine
end)


umg.answer("lootplot:canRemoveItem", function(itemEnt, ppos)
    return not itemEnt.stuck
end)



umg.answer("lootplot:canActivateEntity", function(ent)
    local money = lp.getMoney(ent)
    if money and ent.moneyGenerated and (not ent.canGoIntoDebt) and (ent.moneyGenerated < 0) then
        if ent.moneyGenerated + money < 0 then
            return false
        end
    end
    return true
end)



umg.answer("lootplot:canActivateEntity", function(ent)
    return (ent.activationCount or 0) < (ent.maxActivations or -1)
end)


umg.answer("lootplot:canTrigger", function()
    return true -- need this for AND reducer
end)


umg.answer("lootplot:isEntityTypeUnlocked", function()
    return true -- need this for AND reducer
end)




if server then

local activateInstantly = umg.group("activateInstantly", "item")

local function tryActivateInstantly(ent)
    local slotEnt = lp.itemToSlot(ent)
    if slotEnt and (not lp.canSlotPropagateTriggerToItem(slotEnt)) then
        -- dont activate when in null-slots 
        return
    end
    if not lp.hasBeenMoved(ent) then
        -- if the item hasnt been moved, dont activate it.
        -- we dont want stuff to activate instantly causing infinite loops,
        -- and we dont want the player to get confused by random stuff activating
        return
    end
    local ppos = lp.getPos(ent)
    local plot = ppos and ppos:getPlot()
    if plot and (not plot:isPipelineRunning()) and lp.canActivateEntity(ent) then
        lp.tryActivateEntity(ent)
    end
end

umg.on("@tick", function(dt)
    for _, ent in ipairs(activateInstantly) do
        assert(lp.isItemEntity(ent), "activateInstantly must be item entity!")
        tryActivateInstantly(ent)
    end
end)



umg.on("lootplot:entityActivated", function(ent)
    --[[
    NOTE:
    the order of this is important!
    mult -> bonus -> points
    (Especially for items like toilet-paper)
    ]]
    if ent.multGenerated and ent.multGenerated ~= 0 then
        lp.addPointsMult(ent, ent.multGenerated)
    end

    if ent.bonusGenerated and ent.bonusGenerated ~= 0 then
        lp.addPointsBonus(ent, ent.bonusGenerated)
    end

    if ent.pointsGenerated and ent.pointsGenerated ~= 0 then
        lp.addPoints(ent, ent.pointsGenerated)
    end

    if ent.moneyGenerated and ent.moneyGenerated ~= 0 then
        lp.addMoney(ent, ent.moneyGenerated)
    end

    if ent.grubMoneyCap then
        local money = lp.getMoney(ent)
        if money and money >= ent.grubMoneyCap then
            local delta = money - ent.grubMoneyCap
            lp.subtractMoney(ent, delta)
        end
    end
end)



local FIRST_ORDER = -0xffffffffffff
umg.on("lootplot:entityActivated", FIRST_ORDER, function(ent)
    if ent.doomCount then
        ent.doomCount = ent.doomCount - 1
        local ppos = lp.getPos(ent)
        if ppos and ent.doomCount <= 0 then
            lp.queue(ppos, function()
                if umg.exists(ent) then
                    lp.destroy(ent)
                end
            end)
            lp.wait(ppos, 0.1)
        end
    end

    if ent.foodItem then
        local ppos = lp.getPos(ent)
        if ppos then
            lp.queue(ppos, function()
                if umg.exists(ent) then
                    lp.destroy(ent)
                end
            end)
            lp.wait(ppos, 0.1)
        end
    end
end)



-- sticky/stuck:
umg.on("lootplot:entityActivated", function(ent)
    if ent.sticky and lp.isItemEntity(ent) then
        ent.stuck = true
    end

    if ent.stickySlot and lp.isSlotEntity(ent) then
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            itemEnt.stuck = true
        end
    end
end)



end


