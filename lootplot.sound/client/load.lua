

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
