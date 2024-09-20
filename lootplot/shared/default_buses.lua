

local calls = {
    COMBO = "lootplot:comboChanged",
    POINTS = "lootplot:pointsChanged",
    MONEY = "lootplot:moneyChanged"
}

umg.on("lootplot:attributeChanged", function(attr, ent, delta, oldVal, newVal)
    if calls[attr] then
        umg.call(calls[attr], ent, delta, oldVal, newVal)
    end
end)



local function getVal(ent, val)
    if type(val) == "function" then
        return val(ent)
    end
    return val
end


umg.answer("properties:getPropertyMultiplier", function(ent, prop)
    if ent.lootplotProperties and ent.lootplotProperties.multipliers then
        local val = ent.lootplotProperties.multipliers[prop]
        if val then
            return getVal(ent, val)
        end
    end
    return 1
end)

umg.answer("properties:getPropertyModifier", function(ent, prop)
    if ent.lootplotProperties and ent.lootplotProperties.modifiers then
        local val = ent.lootplotProperties.modifiers[prop]
        if val then
            return getVal(ent, val)
        end
    end
    return 0
end)


umg.answer("properties:getPropertyClamp", function(ent, prop)
    local min, max = -math.huge, math.huge

    if ent.lootplotProperties and ent.lootplotProperties.maximums then
        local val = ent.lootplotProperties.maximums[prop]
        if val then
            max = getVal(ent, val)
        end
    end

    if ent.lootplotProperties and ent.lootplotProperties.minimums then
        local val = ent.lootplotProperties.minimums[prop]
        if val then
            min = getVal(ent, val)
        end
    end

    return min, max
end)



umg.answer("lootplot:hasPlayerAccess", function(ent)
    local ppos = lp.getPos(ent)
    if ppos then
        return not ppos:getPlot():isPipelineRunning()
    end
    return true
end)


umg.answer("lootplot:hasPlayerAccess", function(ent)
    local slotEnt = lp.isItemEntity(ent) and lp.itemToSlot(ent)

    if slotEnt then
        return not slotEnt.shopLock
    end

    return true
end)


umg.answer("lootplot:canAddItemToSlot", function(slotEnt)
    -- button slots cant hold items!
    return not slotEnt:hasComponent("buttonSlot")
end)

umg.answer("lootplot:canRemoveItemFromSlot", function(slotEnt, _)
    -- we need this to return true coz we are using AND reducer!
    return true
end)



umg.answer("lootplot:canActivateEntity", function(ent)
    local money = lp.getMoney(ent)
    if ent.moneyGenerated and money then
        if ent.moneyGenerated + money < 0 then
            return false
        end
    end
    return true
end)



umg.answer("lootplot:canActivateEntity", function(ent)
    return (ent.activationCount or 0) < (ent.maxActivations or -1)
end)



if server then
    
umg.on("lootplot:entityActivated", function(ent)
    if ent.pointsGenerated and ent.pointsGenerated ~= 0 then
        lp.addPoints(ent, ent.pointsGenerated)
    end

    if ent.moneyGenerated and ent.moneyGenerated ~= 0 then
        lp.addMoney(ent, ent.moneyGenerated)
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
        end
    end
end)



umg.on("lootplot:entityDestroyed", function(ent)
    -- TODO: Maybe we should ask: `lootplot:shouldReviveEntity` here..?
    -- instead of just checking `.lives` directly.
    ----
    -- That would allove for future systems to revive entities, 
    -- in whatever way they want.
    if ent.lives and ent.lives > 0 then
        ent.lives = ent.lives - 1
        local ppos = lp.getPos(ent)
        if not ppos then
            return
        end

        local cloneEnt = ent:clone()

        if cloneEnt.doomCount and cloneEnt.doomCount <= 0 then
            -- HACK: Set doomCount directly here.
            -- For future, we prolly wanna be emitted event-bus, 
            -- like `lootplot:entityRevived` or something.
            cloneEnt.doomCount = 1
        end
        if lp.isSlotEntity(ent) then
            lp.setSlot(ppos, cloneEnt)
        elseif lp.isItemEntity(ent) then
            local ok = lp.forceSetItem(ppos, cloneEnt)
            if not ok then
                cloneEnt:delete()
            end
        else
            umg.log.warn("`.lives` component doesn't work on this ent: ", ent)
        end
    end
end)



end


