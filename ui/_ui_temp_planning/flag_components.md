

# Flag components:

BIG QUESTION TIME:

Do we need flag-components?????
The flag component we would have:
`openable`


I guess it'd be good, since we could do stuff like:
```lua

local clickToOpenGroup = umg.group("openable", "x", "y")

onMousepress(function(...)
    local player = getPlayer()
    for ent in clickToOpenGroup do
        if clickedOn(ent) then
            ui.openWith(ent, player)
        end
    end
end)
```

