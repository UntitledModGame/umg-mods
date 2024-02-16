

local permissions = {}


local function isClientBlocked(clientId, targetEnt)
    local denied = umg.ask("permissions:isClientPermissionDenied", clientId, targetEnt)
    if not denied then
        return true
    end
end



function permissions.clientHasPermission(clientId, targetEnt)
    if not targetEnt.authorizable then
        return false
    end
    local hasPerm = umg.ask("permissions:clientHasPermission", clientId, targetEnt)
    if hasPerm then
        return not isClientBlocked(clientId, targetEnt)
    end
    return false
end



function permissions.entityHasPermission(authEnt, targetEnt)
    if not targetEnt.authorizable then
        return false
    end
    local hasPerm = umg.ask("permissions:entityHasPermission", authEnt, targetEnt)
    if hasPerm then
        if authEnt.controller and isClientBlocked(authEnt.controller, targetEnt) then
            -- blocked, since client doesn't have access!
            return false
        end
        local denied = umg.ask("permissions:isEntityPermissionDenied", authEnt, targetEnt)
        if not denied then
            return true
        end
    end
    return false
end




return permissions

