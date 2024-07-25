

local dirObj = umg.newDirectoryObject("assets/sfx")

audio.defineAudioInDirectory(
    dirObj, "lootplot.sound:", {"audio:sfx"}
)


umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        audio.play("lootplot.sound:activate", {
            entity = ent
        })
    else

    end
end)


umg.on("lootplot:pointsChanged", function(ent)
    audio.play("lootplot.sound:collect_point", {
        entity = ent
    })
end)


umg.on("lootplot:entityActivationBlocked", function(ent)
    audio.play("lootplot.sound:deny_activation", {
        entity = ent
    })
end)


umg.on("lootplot:selectionChanged", function(selection)
    if selection then
        audio.play("lootplot.sound:select_item", {
            entity = selection.slot
        })
    else
        -- TODO:
        -- play sound for selection deselect?
    end
end)

