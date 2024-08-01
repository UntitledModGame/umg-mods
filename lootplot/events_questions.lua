

umg.defineEvent("lootplot:itemAddedToSlot")
umg.defineEvent("lootplot:itemRemovedFromSlot")

umg.defineEvent("lootplot:traitAdded")
umg.defineEvent("lootplot:traitRemoved")

umg.defineEvent("lootplot:entitySpawned")
umg.defineEvent("lootplot:entityDestroyed")
umg.defineEvent("lootplot:entityActivated")
umg.defineEvent("lootplot:entityActivationBlocked")
umg.defineQuestion("lootplot:isActivationBlocked", reducers.OR)

umg.defineEvent("lootplot:entityReset")

umg.defineEvent("lootplot:entityBuffed")

umg.defineEvent("lootplot:entityTriggered")
umg.defineQuestion("lootplot:isTriggerBlocked", reducers.OR)

umg.defineEvent("lootplot:itemMoved")

umg.defineEvent("lootplot:moneyChanged")
umg.defineEvent("lootplot:pointsChanged")
umg.defineEvent("lootplot:comboChanged")


umg.defineQuestion("lootplot:getEntityTypeSpawnChance", reducers.MULTIPLY)

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

    umg.defineEvent("lootplot:denySlotInteraction")

    umg.defineEvent("lootplot:tryMoveItemsClient")

    umg.defineQuestion("lootplot:getItemTargetPosition", reducers.PRIORITY_DOUBLE)
end
