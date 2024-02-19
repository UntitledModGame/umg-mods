

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

```


<br/>
<br/>
<br/>
<br/>



-----


# Implementation:
```lua
components.project("clickToOpenUI", "authorizeInRange", function(ent)
    local authorizeInRange = {
        --[[
            The reason we put a slightly smaller distance here,
            Is because we don't want to lose permission as soon as we
            move 1 pixel out of range.
            It's much more ergonomic to have leighway! :)
        ]]
        distance = ent.authorizeInRange.distance * 1.3
    }
    return authorizeInRange
end)

components.project("clickToOpenUI", "clickable")




umg.on("interaction:entityClicked", function(clickedEnt)
    if ent.clickToOpenUI then
        local controlEnt = getAuthorizedControlEntity(ent)
        if controlEnt then
            ui.open(clickedEnt)
        end
    end
end)


components.project("authorizeInRange", "authorizable")

umg.on("permissions:entityHasPermission", function(queryEnt, authEnt)
    local iirange = authEnt.authorizeInRange
    if iirange then
        return spatial.distance(queryEnt, authEnt) <= iirange.distance
    end
end)

```


