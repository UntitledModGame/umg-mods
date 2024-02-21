
--[[

Grant authorization (via permissions mod)
to any entity in range of the `authEnt`, 
(given the authEnt has authorizeInRange component.)


]]


components.project("authorizeInRange", "authorizable")


umg.on("permissions:entityHasPermission", function(queryEnt, authEnt)
    local airange = authEnt.authorizeInRange
    if airange then
        return spatial.distance(queryEnt, authEnt) <= airange.distance
    end
end)

