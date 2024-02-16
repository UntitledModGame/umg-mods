



umg.answer("permissions:entityHasPermission", function(queryEnt, authEnt)
    -- entities have permission if the controllers match :)
    return queryEnt.controller == authEnt.controller
end)

