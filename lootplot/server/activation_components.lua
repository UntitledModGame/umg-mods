


umg.on("lootplot:entityActivated", function(ent)
    if ent.pointsGenerated and ent.pointsGenerated ~= 0 then
        lp.addPoints(ent, ent.pointsGenerated)
    end

    if ent.moneyGenerated and ent.moneyGenerated ~= 0 then
        lp.addMoney(ent, ent.moneyGenerated)
    end
end)


umg.answer("lootplot:isActivationBlocked", function(ent)
    print(ent.activationCount or 0, ent.maxActivations)
    return (ent.activationCount or 0) >= ent.maxActivations
end)


local ORDER=10
umg.on("lootplot:entityTriggered", ORDER, function(name, ent)
    -- reset activationCount on RESET trigger.

    -- TODO: Should this be here...??? its a bit... weird.
    -- it doesn't feel "right" checking the RESET trigger directly... mehhh
    if name == "RESET" then
        ent.activationCount = 0
    end
end)

