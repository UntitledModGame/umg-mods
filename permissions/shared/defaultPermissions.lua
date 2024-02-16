

components.project("permissions", "authorizable")



umg.answer("permissions:entityHasPermission", function(queryEnt, authEnt)
    -- entities have permission if the controllers match :)
    if queryEnt.controller == authEnt.controller then
        return true
    end

    -- permissions.public implies that the entity is publically accessible
    local perms = authEnt.permissions
    if perms then
        if perms.public then
            return true
        end

        if perms.playerOnly then
            local isPlayer = (queryEnt.controller and queryEnt.controllable)
            if isPlayer then
                return true
            end
        end
    end
end)

