


# interaction mod components:

```lua

ent.authorizeInRange = {
    distance = 100
}


ent.clickToOpenUI = true


ent.uiProperties = {
    draggable = true, -- drag with mouse
    clamped = true, -- clamped within screen
    toggleable = true, -- press `KEY` to open/close
}


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


ent.basicUI = {
    openSound = "open_chest",
    closeSound = "close_chest",
    -- todo ^^^ is sound even implemented???

    interactionDistance = 100
}


