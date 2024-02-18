

# interaction mod PLANNIN.


OK... remember:
TOP PRIORITY:
We wanna make it EASY AF to use.

The modder shouldn't even need to THINK when using this system.

Component idea:
```lua

authorizeInRange = {
    distance = 100, -- Entities can interact 500 pixels away
}


clickToInteract = {
    distance = X
}

components.project("clickToInteract", "authorizeInRange", function(ent)
    local authorizeInRange = {
        --[[
            The reason we put a slightly smaller distance here,
            is because we dont want the interaction-distance to be entirely
        ]]
        distance = ent.authorizeInRange.distance * 0.8
    }
    return authorizeInRange
end)

components.project("clickToInteract", "clickable")



umg.on("interaction:entityClicked", function(ent)
    
end)



components.project("authorizeInRange", "authorizable")

umg.on("permissions:entityHasPermission", function(queryEnt, authEnt)
    local iirange = authEnt.authorizeInRange
    if iirange then
        return spatial.distance(queryEnt, authEnt) <= iirange.distance
    end
end)

```


