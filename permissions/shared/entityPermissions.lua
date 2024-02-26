

local permissions = {}



function permissions.entityHasPermission(actorEnt, authEnt)
    --[[
        asks:
        "does actorEnt have access/permission to authEnt?"

        think of `actorEnt` like a player trying to access a chest.
        Think of `authEnt` as a (potentially locked) chest.

        returns true/false depending on 
        whether `actorEnt` has permission, or not.
        (ie. if the chest is unlocked)

    ]]
    if not authEnt.authorizable then
        return false
    end

    local hasPerm = umg.ask("permissions:entityHasPermission", actorEnt, authEnt)
    if hasPerm then
        local denied = umg.ask("permissions:isEntityPermissionDenied", actorEnt, authEnt)
        return not denied
    end
    return false
end




return permissions

