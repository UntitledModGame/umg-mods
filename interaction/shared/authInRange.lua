
--[[

Grant authorization (via permissions mod)
to any entity in range of the `authEnt`, 
(given the authEnt has authorizeInRange component.)


]]


components.project("authorizeInRange", "authorizable")


umg.answer("permissions:entityHasPermission", function(actorEnt, authEnt)
    local airange = authEnt.authorizeInRange
    if airange then
        return spatial.distance(actorEnt, authEnt) <= airange.distance
    end
end)


--[[
    TODO: Should we block permission if `actorEnt` is NOT in range?
    hmmm...
]]

