

umg.answer("lootplot:hasPlayerAccess", function(ent)
    local ppos = lp.getPos(ent)
    if ppos then
        return not ppos:getPlot():isPipelineRunning()
    end
    return true
end)

umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    return ent.ownerPlayer == clientId
end)

umg.answer("lootplot:hasPlayerAccess", function(ent)
    local slotEnt = lp.isItemEntity(ent) and lp.itemToSlot(ent)

    if slotEnt then
        return not slotEnt.shopLock
    end

    return true
end)

umg.answer("lootplot:isItemAdditionBlocked", function(slotEnt)
    -- shop slots cant hold items!
    return not not slotEnt:hasComponent("shopLock")
end)

umg.answer("lootplot:isItemAdditionBlocked", function(slotEnt)
    -- button slots cant hold items!
    return not not slotEnt:hasComponent("buttonSlot")
end)


umg.answer("lootplot:isActivationBlocked", function(ent)
    local money = lp.getMoney(ent)
    if ent.moneyGenerated and money then
        if ent.moneyGenerated + money < 0 then
            print("YO?",ent.moneyGenerated, money)
            return true
        end
    end
    return false
end)



umg.answer("lootplot:isActivationBlocked", function(ent)
    return (ent.activationCount or 0) >= ent.maxActivations
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




--[[
TODO:
should these be here???
Hmm...
]]
umg.on("lootplot:entityActivated", function(ent)
    lp.incrementCombo(ent)
end)
umg.on("lootplot:entityReset", function(ent)
    --[[
    TODO: does this even make sense??
    ]]
    lp.resetCombo(ent)
end)



end


