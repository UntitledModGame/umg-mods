


local currentTick = 0

umg.on("@tick", function()
    currentTick = currentTick + 1
end)


--- A special `on` function that only applies a maximum of ONCE per tick.
--- Useful for sound effects and popup-visuals
---@param event string
---@param func fun(...): boolean
local function limitedOn(event, func)
    local lastTick = 0
    
    umg.on(event, function(a,b,c,d,e)
        if currentTick == lastTick then
            -- we have already activated this tick!!!
            return -- exit early.
        end

        local triggered = func(a,b,c,d,e)
        if triggered then
            lastTick = currentTick
        end
    end)
end




local LootplotSound = require("client.LootplotSound")

local dirObj = umg.getModFilesystem()

audio.defineAudioInDirectory(
    dirObj:cloneWithSubpath("assets/sfx"), {"audio:sfx"}, "lootplot.sound:"
)


local activateItem = LootplotSound("lootplot.sound:activate_item", 0.7, 1)

local activateSlot = LootplotSound("lootplot.sound:click", 0.15, 0.25)
local activateButtonSlot = LootplotSound("lootplot.sound:click", 0.72, 1)

limitedOn("lootplot:entityActivated", function(ent)
    if lp.isItemEntity(ent) then
        activateItem:play(ent)
    elseif lp.isSlotEntity(ent) then
        if ent.buttonSlot then
            activateButtonSlot:play(ent)
        else
            activateSlot:play(ent)
        end
    end
    return true
end)


local pointsEarned = LootplotSound("lootplot.sound:collect_point", 1, 0.8, nil, 0.15)
local pointsStolen = LootplotSound("lootplot.sound:steal_point", 0.7, 1.6, 10, 0.1)

limitedOn("lootplot:pointsChangedViaCall", function(ent, delta)
    if delta > 0.5 then
        pointsEarned:play(ent)
        return true
    elseif delta < -0.5 then
        pointsStolen:play(ent)
        return true
    end
    return false
end)



local BONUS_VOL = 0.7
local pointsEarnedViaBonus = LootplotSound("lootplot.sound:points_changed_via_bonus", BONUS_VOL, 0.65, nil, 0.1)
local pointsStolenViaBonus = LootplotSound("lootplot.sound:points_changed_via_bonus", BONUS_VOL, 0.5, nil, 0.1)

limitedOn("lootplot:pointsChangedViaBonus", function(ent, delta)
    if delta > 0.5 then
        pointsEarnedViaBonus:play(ent)
        return true
    elseif delta < -0.5 then
        pointsStolenViaBonus:play(ent)
        return true
    end
    return false
end)


-- play the same sounds for bonus changed:
limitedOn("lootplot:bonusChanged", function(ent, delta)
    if delta > 0.5 then
        pointsEarnedViaBonus:play(ent)
        return true
    elseif delta < -0.5 then
        pointsStolenViaBonus:play(ent)
        return true
    end
    return false
end)




local MULT_VOL = 0.8
local multIncreased = LootplotSound("lootplot.sound:multiplier_increased", MULT_VOL,1.2, nil, 0.1)
local multDecreased = LootplotSound("lootplot.sound:multiplier_increased", MULT_VOL,0.7, nil, 0.1)
limitedOn("lootplot:multChanged", function(ent, delta)
    if delta > 0.01 then
        multIncreased:play(ent)
        return true
    elseif delta < -0.01 then
        multDecreased:play(ent)
        return true
    end
    return false
end)




local moneyChanged = LootplotSound("lootplot.sound:collect_money", 0.6, 0.8, nil, 0.15)
limitedOn("lootplot:moneyChanged", function(ent, delta)
    if delta > 0.1 then
        moneyChanged:play(ent)
        return true
    end
    return false
end)



local entityActivationBlocked = LootplotSound("lootplot.sound:deny_activation", 0.15, 1, 15)
limitedOn("lootplot:entityActivationBlocked", function(ent)
    entityActivationBlocked:play(ent)
    return true
end)


local wooshSound = sound.RandomSound(
    LootplotSound("lootplot.sound:woosh1a", 0.8, 1, 10, 0.2),
    LootplotSound("lootplot.sound:woosh2a", 0.55, 1, 10, 0.2)
)
limitedOn("lootplot:itemMoved", function(ent)
    wooshSound:play(ent)
    return true
end)


local targetActivated = LootplotSound("lootplot.sound:activate_item", 0.4, 0.6, 20, 0.3)
limitedOn("lootplot.targets:targetActivated", function(ent)
    targetActivated:play(ent)
    return true
end)


local spawnItem = LootplotSound("lootplot.sound:spawn_entity", 1, 1.5, 10, 0.4)
local spawnSlot = LootplotSound("lootplot.sound:spawn_entity", 1, 1.5, 10, 0.4)

limitedOn("lootplot:entitySpawned", function(ent)
    if lp.isItemEntity(ent) then
        spawnItem:play(ent)
        return true
    else
        spawnSlot:play(ent)
        return true
    end
end)


-- local select = LootplotSound("lootplot.sound:select_item", 0.11, 2, 20)
-- local reverseSelect = LootplotSound("lootplot.sound:reverse_select_item", 0.11, 2, 20)

local select = LootplotSound("lootplot.sound:select_item_2", 0.71, 1.3, 20, 0.15)
local reverseSelect = LootplotSound("lootplot.sound:select_item_2", 0.71, 0.6, 20, 0.15)

limitedOn("lootplot:selectionChanged", function(selection)
    if selection then
        local ent = selection.item or selection.slot
        select:play(ent)
        return true
    else
        reverseSelect:play()
        return true
    end
end)


local entBuffed = LootplotSound("lootplot.sound:buff_chomp", 0.1, 1, 5, 0.1)
limitedOn("lootplot:entityBuffed", function(ent)
    entBuffed:play(ent)
    return true
end)



local rotateItem = LootplotSound("lootplot.sound:rotate_item", 1.2, 0.8, 5, 0.1)
limitedOn("lootplot:itemRotated", function(ent)
    rotateItem:play(ent)
    return true
end)



local buySound = LootplotSound("lootplot.sound:trigger_buy", 0.12, 1, 10, 0.1)
local rerollSound = LootplotSound("lootplot.sound:trigger_reroll", 0.07, 1.4, 10, 0)

limitedOn("lootplot:entityTriggered", function (triggerName, ent)
     if triggerName == "BUY" then
        buySound:play(ent)
        return true
    elseif triggerName == "REROLL" then
        rerollSound:play(ent)
        return true
    end
    return false
end)

