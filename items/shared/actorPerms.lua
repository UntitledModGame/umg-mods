

components.project("inventory", "authorizable")



local perms = {}



local canRemoveItemTc = typecheck.assert("entity", "number")
function perms.canActorRemoveItem(actorEnt, invEnt, slot)
    -- whether the actorEnt has the authority to remove the
    -- item at slot
    canRemoveItemTc(actorEnt, slot)
    if not perms.canAccess(invEnt, actorEnt) then
        return
    end
    local isBlocked = umg.ask("items:isItemRemovalBlockedForActorEntity", actorEnt, invEnt, slot)
    return not isBlocked
end



local canAddItemTc = typecheck.assert("entity", "entity", "number")
function perms.canActorAddItem(actorEnt, invEnt, itemToBeAdded, slot)
    -- whether the actorEnt has the authority to add
    -- `item` to the slot (slot)
    canAddItemTc(actorEnt, itemToBeAdded, slot)
    if not perms.canAccess(invEnt, actorEnt) then
        return
    end
    local isBlocked = umg.ask("items:isItemAdditionBlockedForActorEntity", actorEnt, invEnt, itemToBeAdded, slot)
    return not isBlocked
end



function perms.canAccess(invEnt, actorEnt)
    return permissions.entityHasPermission(actorEnt, invEnt)
end



return perms

