

local LootplotSound = require("client.LootplotSound")

local dirObj = umg.getModFilesystem()

audio.defineAudioInDirectory(
    dirObj:cloneWithSubpath("assets/sfx"), {"audio:sfx"}, "lootplot.sound:"
)


local activateItem = LootplotSound("lootplot.sound:activate_item", 0.7, 1)

local activateSlot = LootplotSound("lootplot.sound:click", 0.15, 0.25)
local activateButtonSlot = LootplotSound("lootplot.sound:click", 0.72, 1)

umg.on("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        activateItem:play(ent)
    elseif lp.isSlotEntity(ent) then
        if ent.buttonSlot then
            activateButtonSlot:play(ent)
        else
            activateSlot:play(ent)
        end
    end
end)


local pointsEarned = LootplotSound("lootplot.sound:collect_point", 1, 0.8, nil, 0.15)
local pointsStolen = LootplotSound("lootplot.sound:steal_point", 0.7, 1.6, 10, 0.1)

umg.on("lootplot:pointsChangedViaCall", function(ent, delta)
    if delta > 0.5 then
        pointsEarned:play(ent)
    elseif delta < -0.5 then
        pointsStolen:play(ent)
    end
end)



local BONUS_VOL = 0.7
local pointsEarnedViaBonus = LootplotSound("lootplot.sound:points_changed_via_bonus", BONUS_VOL, 0.65, nil, 0.1)
local pointsStolenViaBonus = LootplotSound("lootplot.sound:points_changed_via_bonus", BONUS_VOL, 0.5, nil, 0.1)

umg.on("lootplot:pointsChangedViaBonus", function(ent, delta)
    if delta > 0.5 then
        pointsEarnedViaBonus:play(ent)
    elseif delta < -0.5 then
        pointsStolenViaBonus:play(ent)
    end
end)

-- play the same sounds for bonus changed:
umg.on("lootplot:bonusChanged", function(ent, delta)
    if delta > 0.5 then
        pointsEarnedViaBonus:play(ent)
    elseif delta < -0.5 then
        pointsStolenViaBonus:play(ent)
    end
end)




local MULT_VOL = 0.8
local multIncreased = LootplotSound("lootplot.sound:multiplier_increased", MULT_VOL,1.2, nil, 0.1)
local multDecreased = LootplotSound("lootplot.sound:multiplier_increased", MULT_VOL,0.7, nil, 0.1)
umg.on("lootplot:multChanged", function(ent, delta)
    if delta > 0.01 then
        multIncreased:play(ent)
    elseif delta < -0.01 then
        multDecreased:play(ent)
    end
end)




local moneyChanged = LootplotSound("lootplot.sound:collect_money", 0.6, 0.8, nil, 0.15)
umg.on("lootplot:moneyChanged", function(ent, delta)
    if delta > 0.1 then
        moneyChanged:play(ent)
    end
end)



local entityActivationBlocked = LootplotSound("lootplot.sound:deny_activation", 0.15, 1, 15)
umg.on("lootplot:entityActivationBlocked", function(ent)
    entityActivationBlocked:play(ent)
end)


local wooshSound = sound.RandomSound(
    LootplotSound("lootplot.sound:woosh1a", 0.8, 1, 10, 0.2),
    LootplotSound("lootplot.sound:woosh2a", 0.55, 1, 10, 0.2)
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


-- local select = LootplotSound("lootplot.sound:select_item", 0.11, 2, 20)
-- local reverseSelect = LootplotSound("lootplot.sound:reverse_select_item", 0.11, 2, 20)

local select = LootplotSound("lootplot.sound:select_item_2", 0.71, 1.3, 20, 0.15)
local reverseSelect = LootplotSound("lootplot.sound:select_item_2", 0.71, 0.6, 20, 0.15)

umg.on("lootplot:selectionChanged", function(selection)
    if selection then
        local ent = selection.item or selection.slot
        select:play(ent)
    else
        reverseSelect:play()
    end
end)


local entBuffed = LootplotSound("lootplot.sound:buff_chomp", 0.1, 1, 5, 0.1)
umg.on("lootplot:entityBuffed", function(ent)
    entBuffed:play(ent)
end)



local rotateItem = LootplotSound("lootplot.sound:rotate_item", 1.2, 0.8, 5, 0.1)
umg.on("lootplot:itemRotated", function(ent)
    rotateItem:play(ent)
end)



local buySound = LootplotSound("lootplot.sound:trigger_buy", 0.12, 1, 10, 0.1)
local rerollSound = LootplotSound("lootplot.sound:trigger_reroll", 0.07, 1.4, 10, 0)
local function tryPlayTriggerSound(triggerName, ent)
    if triggerName == "BUY" then
        buySound:play(ent)
    elseif triggerName == "REROLL" then
        rerollSound:play(ent)
    end
end
umg.on("lootplot:entityTriggered", tryPlayTriggerSound)
