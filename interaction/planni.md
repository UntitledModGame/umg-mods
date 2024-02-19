

# interaction mod PLANNIN.


OK... remember:
TOP PRIORITY:
We wanna make it EASY AF to use.

The modder shouldn't even need to THINK when using this stuff.

Component idea:
```lua

authorizeInRange = {
    distance = 100, -- Entities can interact X units away
}


clickToOpenUI = {
    -- if the client is controlling an entity within `distance` units,
    --  then this entity can be clicked / interacted with.
    distance = X
}

components.project("clickToOpenUI", "authorizeInRange", function(ent)
    local authorizeInRange = {
        --[[
            The reason we put a slightly smaller distance here,
            is because we dont want the interaction-distance to be entirely
        ]]
        distance = ent.authorizeInRange.distance * 0.8
    }
    return authorizeInRange
end)

components.project("clickToOpenUI", "clickable")




umg.on("interaction:entityClicked", function(ent)
    local ent = findClosestControlEntity(ent)

end)



components.project("authorizeInRange", "authorizable")

umg.on("permissions:entityHasPermission", function(queryEnt, authEnt)
    local iirange = authEnt.authorizeInRange
    if iirange then
        return spatial.distance(queryEnt, authEnt) <= iirange.distance
    end
end)

```


