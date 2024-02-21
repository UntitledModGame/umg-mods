

# clickables components
```lua


-- flag component.
-- Marks the entity as `clickable`. 
-- `:entityClicked` events will now be emitted when ent is clicked.
ent.clickable = true



-- The distance away from the center of `ent` that counts as a mouse click.
-- DEFAULT = 30.
ent.clickableDistance = 30



ent.onClick = function(ent, clientId, button, worldX, worldY)
    if server then
        print("ent was clicked by client: ", clientId)
    elseif clientId == client.getClient() then
        print("you clicked an entity!")
    end
end






```

