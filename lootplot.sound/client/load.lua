

local LootplotSound = require("client.LootplotSound")

local dirObj = umg.newDirectoryObject("assets/sfx")

audio.defineAudioInDirectory(
    dirObj, "lootplot.sound:", {"audio:sfx"}
)


local activateItem = LootplotSound("lootplot.sound:activate_item", 0.7, 1, 20)
local activateSlot = LootplotSound("lootplot.sound:activate_slot", 0.05, 1.1, 20)
umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        activateItem:play(ent)
    elseif lp.isSlotEntity(ent) then
        activateSlot:play(ent)
    end
end)


local pointsChanged = LootplotSound("lootplot.sound:collect_point", 1, 0.8, 20, 0.15)
umg.on("lootplot:pointsChanged", function(ent)
    pointsChanged:play(ent)
end)


local entityActivationBlocked = LootplotSound("lootplot.sound:deny_activation", 0.15, 1, 15)
umg.on("lootplot:entityActivationBlocked", function(ent)
    entityActivationBlocked:play(ent)
end)



local targetActivated = LootplotSound("lootplot.sound:activate_item", 0.4, 0.6, 20, 0.3)
umg.on("lootplot.targets:targetActivated", function(ent)
    targetActivated:play(ent)
end)




local select = LootplotSound("lootplot.sound:select_item", 0.36, 1, 20)
umg.on("lootplot:selectionChanged", function(selection)
    if selection then
        select:play(selection.slot)
    else
        -- TODO:
        -- play sound for selection deselect?
    end
end)

