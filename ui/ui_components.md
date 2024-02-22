

# ui components 

```lua


-- Element for ui entities
ent.uiElement = MyLUIElement(...)


-- Kirigami region for ui entiites
-- (This is just the area of space they take up on screen/scene)
ent.uiRegion = ui.Region(x,y,w,h)


-- uiSize will automatically create (and handle) uiRegion
ent.uiSize = {
    -- restricts Region size to a multiple of these numbers
    widthFactorOf = 600,
    heightFactorOf = 400,

    -- width/height, as a ratio of screen
    width = 0.4, 
    height = 0.26 -- eg. 26% of screen height

    noRatio = false -- whether the w/h ratio should be locked.
    -- defaults to nil; ie; there IS a fixed w/h ratio by default
}


ent.initUI = function(ent)
    -- provides an initializer for UI on clientside
    ...
end



```

