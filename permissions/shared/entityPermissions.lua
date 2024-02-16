

local permissions = {}



function permissions.entityHasPermission(authEnt, targetEnt)
    if not targetEnt.authorizable then
        return false
    end
    local hasPerm = umg.ask("permissions:entityHasPermission", authEnt, targetEnt)
    if hasPerm then
        local denied = umg.ask("permissions:isEntityPermissionDenied", authEnt, targetEnt)
        if not denied then
            return true
        end
    end
    return false
end




return permissions

