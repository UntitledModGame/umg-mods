

components.project("permissions", "authorizable")



umg.answer("permissions:entityHasPermission", function(queryEnt, authEnt)
    -- entities have permission if the controllers match :)
    if queryEnt.controller == authEnt.controller then
        return true
    end

    if authEnt.permissions then
        if authEnt.permissions.public then
            return true
        end
    end
end)

