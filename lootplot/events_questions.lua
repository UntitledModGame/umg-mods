

umg.defineEvent("lootplot:itemAddedToSlot")
umg.defineEvent("lootplot:itemRemovedFromSlot")

umg.defineEvent("lootplot:entitySpawned")
umg.defineEvent("lootplot:entityDestroyed")
umg.defineEvent("lootplot:entityActivated")
umg.defineEvent("lootplot:entityActivationBlocked")
umg.defineQuestion("lootplot:canActivateEntity", reducers.AND)

umg.defineEvent("lootplot:entityReset")

umg.defineEvent("lootplot:entityBuffed")

umg.defineEvent("lootplot:entityTriggered")
umg.defineEvent("lootplot:entityTriggerFailed")
umg.defineQuestion("lootplot:canTrigger", reducers.AND)

umg.defineEvent("lootplot:itemMoved")

umg.defineEvent("lootplot:itemRotated")


umg.defineEvent("lootplot:attributeChanged")

umg.defineEvent("lootplot:moneyChanged")
umg.defineEvent("lootplot:pointsChanged") -- (includes bonus AND normal changes)
umg.defineEvent("lootplot:bonusChanged")
umg.defineEvent("lootplot:multChanged")
umg.defineEvent("lootplot:comboChanged")


umg.defineEvent("lootplot:pointsChangedViaCall")
umg.defineEvent("lootplot:pointsChangedViaBonus")
-- These callbacks allow us to differentiate between bonus-mechanism and points-mechanism



umg.defineEvent("lootplot:plotFogChanged")


umg.defineEvent("lootplot:populateSelectionButtons")



umg.defineQuestion("lootplot:canCombineItems", reducers.OR)
umg.defineEvent("lootplot:itemsCombined")


umg.defineEvent("lootplot:winGame")
umg.defineEvent("lootplot:loseGame")


if server then
    umg.defineQuestion("lootplot:getPipelineDelayMultiplier", reducers.MULTIPLY)
    umg.defineQuestion("lootplot:getPipelineDelay", reducers.ADD)
end


umg.defineQuestion("lootplot:canRemoveItem", reducers.AND)
umg.defineQuestion("lootplot:canAddItem", reducers.AND)

umg.defineQuestion("lootplot:canItemFloat", reducers.OR)

umg.defineQuestion("lootplot:hasPlayerAccess", reducers.AND)



-- whether an entity type is unlocked or not
umg.defineQuestion("lootplot:isEntityTypeUnlocked", reducers.AND)





if client then
    umg.defineEvent("lootplot:selectionChanged")
    umg.defineEvent("lootplot:hoverChanged")

    umg.defineEvent("lootplot:populateTriggerDescription")
    umg.defineEvent("lootplot:populateActivateDescription")
    umg.defineEvent("lootplot:populateMetaDescription")
    umg.defineEvent("lootplot:populateDescriptionTags")

    umg.defineEvent("lootplot:denySlotInteraction")

    umg.defineEvent("lootplot:tryMoveItemsClient")

    umg.defineQuestion("lootplot:getItemTargetPosition", reducers.PRIORITY_DOUBLE)
end
