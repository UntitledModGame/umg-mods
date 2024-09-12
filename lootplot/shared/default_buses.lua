

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

end


