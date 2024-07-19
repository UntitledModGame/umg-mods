

umg.defineEvent("lootplot:itemAddedToSlot")
umg.defineEvent("lootplot:itemRemovedFromSlot")



umg.defineEvent("lootplot:plotActivated")

umg.defineEvent("lootplot:entitySpawned")
umg.defineEvent("lootplot:entityActivated")
umg.defineEvent("lootplot:entityActivationBlocked")
umg.defineQuestion("lootplot:isActivationBlocked", reducers.OR)

umg.defineEvent("lootplot:entityReset")


umg.defineEvent("lootplot:entityTriggered")
umg.defineQuestion("lootplot:isTriggerBlocked", reducers.OR)


umg.defineEvent("lootplot:moneyChanged")
umg.defineEvent("lootplot:pointsChanged")


umg.defineQuestion("lootplot:pollSelectionButtons", reducers.SINGLE_COLLECT)

umg.defineQuestion("lootplot:getMoneyMultiplier", reducers.MULTIPLY)
umg.defineQuestion("lootplot:getPointMultiplier", reducers.MULTIPLY)


umg.defineQuestion("lootplot:getPipelineDelayMultiplier", reducers.MULTIPLY)
umg.defineQuestion("lootplot:getPipelineDelay", reducers.ADD)


umg.defineQuestion("lootplot:isItemRemovalBlocked", reducers.OR)
umg.defineQuestion("lootplot:isItemAdditionBlocked", reducers.OR)


umg.defineQuestion("lootplot:hasPlayerAccess", reducers.AND)

if client then
    umg.defineEvent("lootplot:selectionChanged")

    umg.defineEvent("lootplot:endHoverItem")
    umg.defineEvent("lootplot:startHoverItem")
    umg.defineEvent("lootplot:endHoverSlot")
    umg.defineEvent("lootplot:startHoverSlot")

    umg.defineEvent("lootplot:populateDescription")
end
