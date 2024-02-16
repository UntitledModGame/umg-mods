

local permissions = {}



components.project("hasPermission", "authorizable")



function permissions.entityHasPermission(queryEnt, authEnt)
    --[[
        asks:
        "does queryEnt have access/permission to authEnt?"

        think of `queryEnt` like a player trying to access a chest.
        Think of `authEnt` as a (potentially locked) chest.

        returns true/false depending on 
        whether `queryEnt` has permission, or not.
        (ie. if the chest is unlocked)

    ]]
    if not authEnt.authorizable then
        return false
    end

    local hasPerm = umg.ask("permissions:entityHasPermission", queryEnt, authEnt)
    if hasPerm then
        local denied = umg.ask("permissions:isEntityPermissionDenied", queryEnt, authEnt)
        if not denied then
            return true
        end
    end
    return false
end




return permissions

