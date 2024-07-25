

local LootplotSound = require("client.LootplotSound")

local dirObj = umg.newDirectoryObject("assets/sfx")

audio.defineAudioInDirectory(
    dirObj, "lootplot.sound:", {"audio:sfx"}
)


local activateItem = LootplotSound("lootplot.sound:activate_item", 0.7, 1)
local activateSlot = LootplotSound("lootplot.sound:activate_slot", 0.05, 1.1)
umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        activateItem:play(ent)
    elseif lp.isSlotEntity(ent) then
        activateSlot:play(ent)
    end
end)


local pointsChanged = LootplotSound("lootplot.sound:collect_point", 1, 0.8, nil, 0.15)
umg.on("lootplot:pointsChanged", function(ent, delta)
    if delta > 0.5 then
        pointsChanged:play(ent)
    end
end)


local entityActivationBlocked = LootplotSound("lootplot.sound:deny_activation", 0.15, 1, 15)
umg.on("lootplot:entityActivationBlocked", function(ent)
    entityActivationBlocked:play(ent)
end)


local wooshSound = sound.RandomSound(
    LootplotSound("lootplot.sound:woosh1", 0.8, 1, 10, 0.2),
    LootplotSound("lootplot.sound:woosh2", 0.55, 1, 10, 0.2)
)
umg.on("lootplot:itemMoved", function(ent)
    wooshSound:play(ent)
end)


local targetActivated = LootplotSound("lootplot.sound:activate_item", 0.4, 0.6, 20, 0.3)
umg.on("lootplot.targets:targetActivated", function(ent)
    targetActivated:play(ent)
end)


local spawnItem = LootplotSound("lootplot.sound:spawn_entity", 1, 1.5, 10, 0.4)
local spawnSlot = LootplotSound("lootplot.sound:spawn_entity", 1, 1.5, 10, 0.4)
umg.on("lootplot:entitySpawned", function(ent)
    if lp.isItemEntity(ent) then
        spawnItem:play(ent)
    else
        spawnSlot:play(ent)
    end
end)


local select = LootplotSound("lootplot.sound:select_item", 0.26, 1, 20)
umg.on("lootplot:selectionChanged", function(selection)
    if selection then
        select:play(selection.slot)
    else
        -- TODO:
        -- play sound for selection deselect?
    end
end)

