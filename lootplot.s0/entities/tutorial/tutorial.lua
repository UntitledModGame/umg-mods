
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")



umg.defineEntityType("lootplot.s0:tutorial_text", {
    layer = "world",
    onUpdateClient = function(ent)
        local run = lp.singleplayer.getRun()
        if run then
            local plot = run:getPlot()
            ent.x, ent.y = plot:getPPos(ent.pposX, ent.pposY):getWorldPos()
        end
    end,
})


lp.defineItem("lootplot.s0:tutorial_egg", {
    name = loc("Egg Item"),
    image = "tutorial_egg",
    triggers = {"PULSE"},
    basePointsGenerated = 1,
})

lp.defineSlot("lootplot.s0:tutorial_slot", {
    name = loc("Basic Slot"),
    image = "tutorial_slot",
    description = loc("Holds items"),
    triggers = {"PULSE"},
})


lp.defineSlot("lootplot.s0:tutorial_reroll_button_slot", {
    name = loc("Reroll button"),
    description = loc("Click to trigger {wavy}{lootplot:TRIGGER_COLOR}REROLL{/lootplot:TRIGGER_COLOR} for the whole plot!"),

    image = "tutorial_reroll_button_up",
    activateAnimation = {
        activate = "tutorial_reroll_button_hold",
        idle = "tutorial_reroll_button_up",
        duration = 0.15
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end
        lp.Bufferer()
            :all(ppos:getPlot())
            :withDelay(0.05)
            :to("SLOT_OR_ITEM")
            :execute(function(ppos1, e1)
                lp.resetCombo(e1)
                lp.tryTriggerSlotThenItem("REROLL", ppos1)
            end)
    end,
})


lp.defineItem("lootplot.s0:tutorial_tombstone", {
    name = loc("Tombstone"),
    image = "tutorial_tombstone",
    triggers = {"PULSE"},
    activateDescription = loc("Spawns basic slots"),
    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos)
            lp.trySpawnSlot(ppos, server.entities.slot, selfEnt.lootplotTeam)
        end
    }
})




-- ids of button-ents for the tutorial
local NEXT_TUTORIAL_BUTTON = "lootplot.s0:next_tutorial_stage_button"
local PREV_TUTORIAL_BUTTON = "lootplot.s0:previous_tutorial_stage_button"



---@param tutEnt Entity
local function clearText(tutEnt)
    local ppos = assert(lp.getPos(tutEnt))
    ---@type lootplot.Plot
    local plot = ppos:getPlot()
    plot:foreachLayerEntry(function(ent, _ppos, layer)
        if layer == "world" then
            ent:delete()
        end
    end)
end


---@param ent Entity
---@param dx number
---@param dy number
---@return lootplot.PPos
local function fromMiddle(ent, dx,dy)
    local ppos = assert(lp.getPos(ent))
    local midPos = assert(ppos:getPlot():getCenterPPos())
    return assert(midPos:move(dx,dy))
end

---@param tutEnt Entity
---@param dx number
---@param dy number
---@param txt string
---@return Entity
local function addText(tutEnt, dx,dy, txt)
    local textPos = fromMiddle(tutEnt, dx,dy)
    if not txt:match("%{outline%}") then
        txt = "{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}" .. txt
    end

    local textEnt = server.entities.tutorial_text()
    textEnt.text = txt
    local x,y = textPos:getCoords()
    textEnt.pposX, textEnt.pposY = x,y

    textPos:getPlot():set(x,y, textEnt)
    return textEnt
end


---@param tutEnt Entity
---@param dx number
---@param dy number
---@param slotName string
---@return (EntityClass|lootplot.LayerEntityClass|lootplot.SlotEntityClass|table<string, any>)?
local function spawnSlot(tutEnt, dx,dy, slotName)
    local ppos = fromMiddle(tutEnt, dx,dy)
    local etype = server.entities[slotName]
    return lp.trySpawnSlot(ppos, etype, tutEnt.lootplotTeam)
end


---@param tutEnt Entity
---@param dx number
---@param dy number
---@param itemName string
---@return Entity?
local function spawnItem(tutEnt, dx,dy, itemName)
    spawnSlot(tutEnt, dx,dy, "tutorial_slot")
    local ppos = fromMiddle(tutEnt, dx,dy)
    local etype = server.entities[itemName]
    return lp.forceSpawnItem(ppos, etype, tutEnt.lootplotTeam)
end


---@param tutEnt Entity
---@param dx number
---@param dy number
---@param itemName string
---@return Entity?
local function spawnFloatingItem(tutEnt, dx,dy, itemName)
    local slotEnt = spawnSlot(tutEnt, dx,dy, "tutorial_slot")
    local ppos = fromMiddle(tutEnt, dx,dy)
    local etype = server.entities[itemName]
    local e = lp.forceSpawnItem(ppos, etype, tutEnt.lootplotTeam)
    if not e then return nil end
    e.canItemFloat = true
    if slotEnt then
        lp.destroy(slotEnt)
    end
    return e
end





local function clearEverything(tutEnt)
    local tutPos = assert(lp.getPos(tutEnt))
    clearText(tutEnt)
    tutPos:getPlot():foreachLayerEntry(function (ent, ppos, layer)
        ppos:clear(layer)
        ent:delete()
    end)
end




local function clearEverythingExceptButtons(tutEnt)
    local tutPos = assert(lp.getPos(tutEnt))
    tutPos:getPlot():foreachLayerEntry(function (ent, ppos, layer)
        if ent:type()~=NEXT_TUTORIAL_BUTTON and ent:type()~=PREV_TUTORIAL_BUTTON then
            ppos:clear(layer)
            ent:delete()
        else
            -- We need to reset activations on tutorial-buttons; or else they may not be reset!
            -- (Consider player spamming buttons going back and forth)
            lp.resetEntity(ent)
        end
    end)
    clearText(tutEnt)
end


local function clearAllButtonSlots(tutEnt)
    local tutPos = assert(lp.getPos(tutEnt))
    tutPos:getPlot():foreachSlot(function (ent, ppos)
        if ent.buttonSlot then
            ent:delete()
            ppos:clear("slot")
        end
    end)
end




local function clearEverythingExceptSelf(selfEnt)
    local tutPos = assert(lp.getPos(selfEnt))
    tutPos:getPlot():foreachLayerEntry(function (ent, ppos, layer)
        if ent ~= selfEnt then
            ppos:clear(layer)
            ent:delete()
        end
    end)
    clearText(selfEnt)
end




---@param ent Entity
local function resetPlot(ent, ppos)
    local plot = ppos:getPlot()
    lp.queue(ppos, function()
        -- This will execute LAST.
        plot:foreachLayerEntry(function(e, _ppos, layer)
            lp.resetEntity(e)
        end)
        lp.setPointsMult(ent, 1)
        lp.setPointsBonus(ent, 0)
    end)
end

local function buttonOnDraw(ent)
    -- NOTE: this is a bit weird/hacky, 
    -- since we aren't actually drawing anything..
    -- but its "fine"
    if not lp.canActivateEntity(ent) then
        ent.opacity = 0.3
    else
        ent.opacity = 1
    end
end

lp.defineSlot("lootplot.s0:tutorial_pulse_button_slot", {
    image = "pulse_button_up",

    name = loc("Pulse Button"),
    description = loc("Click to {wavy}{lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR}{/wavy} all items/slots,\nand go to the next round!"),
    activateDescription = loc("(Afterwards, resets item activations.)"),

    activateAnimation = {
        activate = "pulse_button_hold",
        idle = "pulse_button_up",
        duration = 0.1
    },

    onDraw = buttonOnDraw,

    baseMaxActivations = 100,

    triggers = {},
    buttonSlot = true,

    canActivate = function(ent)
        local round = lp.getRound(ent)
        local numOfRounds = lp.getNumberOfRounds(ent)
        if round < (numOfRounds + 1) then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            resetPlot(ent, ppos)
            lp.rawsetAttribute("POINTS", ent, 0)

            local plot = ppos:getPlot()
            lp.Bufferer()
                :all(plot)
                :to("SLOT_OR_ITEM") -- ppos-->slot
                :filter(function(ppos1, e)
                    return lp.hasTrigger(e, "PULSE")
                end)
                :execute(function(ppos2, slotEnt)
                    lp.resetCombo(slotEnt)
                    lp.tryTriggerSlotThenItem("PULSE", ppos2)
                end)

            resetPlot(ent, ppos)
            lp.rawsetAttribute("POINTS", ent, 0)
        end
    end,
})



do

---@param plot lootplot.Plot
---@param x number
---@param y number
---@param func function
local function try(plot, x, y, func)
    local cpos = plot:getCenterPPos()
    local cx,cy = cpos:getCoords()
    local ppos = plot:getPPos(cx+x, cy+y)
    local p0 = helper.getEmptySpaceNear(ppos, 1)
    if p0 then
        func(p0)
    else
        func(ppos)
    end
end

local NUM_ACTS = 10
helper.defineDelayItem("tutorial_treasure_bar", "Treasure Bar", {
    delayCount = NUM_ACTS,

    delayDescription = loc("Spawns items for a treasure-hunt..."),

    delayAction = function(ent)
        local ppos, team = lp.getPos(ent), ent.lootplotTeam
        local plot = assert(ppos):getPlot()

        try(plot, 4, 4, function(p)
            lp.forceSpawnSlot(p, server.entities.null_slot, team)
            local k1 = lp.forceSpawnItem(p, server.entities.key, team)
            if k1 then
                lp.setItemRotation(k1, 0)
            end
        end)

        try(plot, 5, 3, function(p)
            lp.forceSpawnSlot(p, server.entities.null_slot, team)
            lp.forceSpawnItem(p, server.entities.key, team)
        end)

        try(plot, 1, 4, function(p)
            lp.forceSpawnSlot(p, server.entities.null_slot, team)
            lp.forceSpawnItem(p, server.entities.glass_tube, team)
        end)

        try(plot, 2, 5, function(p)
            lp.forceSpawnSlot(p, server.entities.null_slot, team)
            lp.forceSpawnItem(p, server.entities.glass_tube, team)
        end)

        try(plot, 6, 1, function(p)
            local slotEnt = server.entities.null_slot()
            slotEnt.lootplotTeam = team
            local itemEnt = server.entities.copykitten()
            itemEnt.lootplotTeam = team
            itemEnt.doomCount = 5
            lp.unlocks.forceSpawnLockedSlot(p, slotEnt, itemEnt)
        end)

        try(plot, 5, -1, function(p)
            local slotEnt = server.entities.null_slot()
            slotEnt.lootplotTeam = team
            local itemEnt = server.entities.rook_glove()
            itemEnt.lootplotTeam = team
            lp.unlocks.forceSpawnLockedSlot(p, slotEnt, itemEnt)
        end)

        try(plot, 4, -3, function(p)
            local slotEnt = server.entities.null_slot()
            slotEnt.lootplotTeam = team
            local itemEnt = server.entities.ruby_spear()
            itemEnt.lootplotTeam = team
            lp.unlocks.forceSpawnLockedSlot(p, slotEnt, itemEnt)
        end)
        try(plot, 4, 1, function(p)
            local slotEnt = server.entities.null_slot()
            slotEnt.lootplotTeam = team
            local itemEnt = server.entities.ruby_spear()
            itemEnt.lootplotTeam = team
            lp.unlocks.forceSpawnLockedSlot(p, slotEnt, itemEnt)
        end)

        lp.destroy(ent)
    end,

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 4,
    basePointsGenerated = 6,

    rarity = lp.rarities.UNIQUE,
})

end


do

local NEXT_LEVEL = interp("Click to progress to the next level!")
local NEED_POINTS = interp("{c r=1 g=0.6 b=0.5}Need %{pointsLeft} more points!")

local function nextLevelActivateDescription(ent)
    if umg.exists(ent) then
        local points = lp.getPoints(ent)
        local requiredPoints = lp.getRequiredPoints(ent)
        local pointsLeft = requiredPoints - points
        if pointsLeft <= 0 then
            return NEXT_LEVEL({name = lp.getTriggerDisplayName("LEVEL_UP")})
        else
            return NEED_POINTS({
                pointsLeft = pointsLeft
            })
        end
    end
    return ""
end



local function getNumberOfRoundsToSkip(ent)
    local round = lp.getRound(ent)
    local numRounds = lp.getNumberOfRounds(ent)
    -- add 1 because it starts at 1
    return (numRounds + 1) - round
end



local YOU_WIN_TEXT = loc("GG!\nNew items have been unlocked.")

lp.defineSlot("lootplot.s0:tutorial_next_level_button_slot", {
    image = "level_button_up",

    name = loc("Next-Level Button"),
    activateDescription = nextLevelActivateDescription,

    activateAnimation = {
        activate = "level_button_hold",
        idle = "level_button_up",
        duration = 0.1
    },

    baseMaxActivations = 3,
    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.UNIQUE,

    onDraw = buttonOnDraw,

    canActivate = function(ent)
        local level = lp.getLevel(ent) or 0
        local skipCount = getNumberOfRoundsToSkip(ent)
        if (level <= 2) and (skipCount > 0) then
            -- dont allow player to skip the first couple of levels
            -- (its a noob-trap)
            return false
        end
        local requiredPoints = lp.getRequiredPoints(ent)
        local points = lp.getPoints(ent)
        if points >= requiredPoints then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end
        local plot = ppos:getPlot()

        local level = lp.getLevel(ent)
        if level >= lp.getNumberOfLevels(ent) then
            local e = addText(ent, 0, -4, YOU_WIN_TEXT)
            e.scale = 2
            e.color = objects.Color.GREEN

            -- we need to call this, so the run doesn't save.
            lp.loseGame(plot, server.getHostClient())

            clearAllButtonSlots(ent)
            return
        end

        lp.rawsetAttribute("POINTS", ent, 0)
        lp.setRound(ent, 1)
        lp.setLevel(ent, lp.getLevel(ent) + 1)
    end
})

end











local tutorialSections = objects.Array()




do
--[[
Explain PULSE trigger
]]
local MOVEMENT_TEXT = loc("WASD / Right click to move.\nScroll to zoom.")

tutorialSections:add(function(e)
    clearEverythingExceptButtons(e)
    addText(e, 0,2, MOVEMENT_TEXT)
end)
end





do
--[[
Explain SLOTS/ITEMS trigger
]]
local SLOT_ITEM_TXT = loc("In lootplot, there are ITEMS and SLOTS.\nClick on the egg item to move it.")

local ITEM_NAME = loc("Egg Item")
-- its important that it's named "egg item"

tutorialSections:add(function(e)
    clearEverythingExceptButtons(e)

    addText(e, 0,2, SLOT_ITEM_TXT)

    do local etype = assert(server.entities[PREV_TUTORIAL_BUTTON])
    local pos1 = fromMiddle(e, -1, -3)
    lp.trySpawnSlot(pos1, etype, e.lootplotTeam) end

    for x= -1,1 do
        for y = -1,0 do
            spawnSlot(e, x,y, "tutorial_slot")
        end
    end

    local e1 = spawnItem(e, -1,0, "tutorial_egg")
    e1.name = ITEM_NAME
end)
end







do
--[[
Explain PULSE trigger
]]
local TXT = loc("This is the {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} Button.\nIt will trigger {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} on these eggs!")

tutorialSections:add(function(e)
    clearEverythingExceptButtons(e)
    addText(e, -3,0, TXT)
    spawnSlot(e, -3,3, "tutorial_pulse_button_slot")

    for x=2,4 do
        for y=1,4 do
            local slotEnt = spawnSlot(e, x,y, "tutorial_slot")
            if slotEnt and (((x==2) or (x==3)) and (y == 2)) then
                -- give a slot points to explain that slots can activate too!
                lp.modifierBuff(slotEnt, "pointsGenerated", 5)
            end
        end
    end

    spawnItem(e, 3,2, "tutorial_egg")
    spawnItem(e, 4,3, "tutorial_egg")
    spawnItem(e, 2,1, "tutorial_egg")
    spawnItem(e, 3,4, "tutorial_egg")
    spawnItem(e, 4,1, "tutorial_egg")
end)
end



do
--[[
Explain other triggers.
]]
local TXT = loc("Items can have\ndifferent triggers:")

tutorialSections:add(function(e)
    clearEverythingExceptButtons(e)
    addText(e, -3,0, TXT)
    spawnSlot(e, -3,3, "tutorial_pulse_button_slot")
    spawnSlot(e, -4,3, "tutorial_reroll_button_slot")

    spawnItem(e, 3,1, "tutorial_egg")

    local rEgg = assert(spawnItem(e, 3,3, "tutorial_egg"))
    rEgg.triggers = {"REROLL"}
    rEgg.color = objects.Color.GREEN
    sync.syncComponent(rEgg, "triggers")

    local eggMulti = assert(spawnItem(e, 3,5, "tutorial_egg"))
    eggMulti.triggers = {"REROLL","PULSE"}
    eggMulti.color = objects.Color.AQUA
    sync.syncComponent(eggMulti, "triggers")
end)
end




do
--[[
Slot triggers:
]]
local TXT = loc("Slots also have triggers:")

tutorialSections:add(function(e)
    clearEverythingExceptButtons(e)
    addText(e, -3,0, TXT)
    spawnSlot(e, -3,3, "tutorial_pulse_button_slot")
    spawnSlot(e, -4,3, "tutorial_reroll_button_slot")

    local s1 = assert(spawnSlot(e, 3,1, "slot"))
    lp.modifierBuff(s1, "pointsGenerated", 5)

    local rSlot = assert(spawnSlot(e, 3,3, "slot"))
    rSlot.triggers = {"REROLL"}
    lp.modifierBuff(rSlot, "pointsGenerated", 5)
    sync.syncComponent(rSlot, "triggers")

    local multiSlot = assert(spawnSlot(e, 3,5, "slot"))
    multiSlot.triggers = {"REROLL","PULSE"}
    lp.modifierBuff(multiSlot, "pointsGenerated", 5)
    sync.syncComponent(multiSlot, "triggers")
end)
end









do
-- Bonus:
local TXT = loc("{lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} will earn extra points.\n({lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is reset to 0 after the {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR})")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    for x=-4, 4 do
        spawnItem(tutEnt, x, 3, "tutorial_egg")
    end
    
    local e = assert(spawnItem(tutEnt, 0,3, "tutorial_egg"))
    e.baseBonusGenerated = 10
    e.basePointsGenerated = 0
    e.color = {0.15,0.3,0.9}
end)
end


do
-- Negative bonus:
local TXT = loc("{lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} can also be negative!\nWatch out!")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    for x=-4, 4 do
        spawnItem(tutEnt, x, 3, "tutorial_egg")
    end

    do local egg = assert(spawnItem(tutEnt, 0,3, "tutorial_egg"))
    egg.baseBonusGenerated = -10
    egg.basePointsGenerated = 0
    egg.color = {1,0,0} end
end)
end




do
-- Multiplier:
local TXT = loc("{lootplot:POINTS_MULT_COLOR}Multiplier{/lootplot:POINTS_MULT_COLOR} will multiply any points earned.\n(Reset to 1 after Pulse)")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    for x=-4, 4 do
        spawnItem(tutEnt, x, 3, "tutorial_egg")
    end

    local e = assert(spawnItem(tutEnt, 0,3, "iron_spear"))
    e.baseMultGenerated = 2 -- monkeypatch so its clearer.
end)
end








do
-- ITEM visuals:
-- DoomCount, lives, grubby, floating
local TXT = loc("Items can have different properties.\nNotice the visual indicators!")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    do local egg = assert(spawnItem(tutEnt, -4,2, "tutorial_egg"))
    egg.repeatActivations = true end

    do local egg = assert(spawnItem(tutEnt, -3,3, "tutorial_egg"))
    egg.doomCount = 9 end

    assert(spawnFloatingItem(tutEnt, -1,2, "tutorial_egg"))

    do local egg = assert(spawnItem(tutEnt, 1,2, "tutorial_egg"))
    egg.lives = 5 end

    do local egg = assert(spawnItem(tutEnt, 3,3, "tutorial_egg"))
    egg.grubMoneyCap = 5 end

    do local egg = assert(spawnItem(tutEnt, 4,2, "tutorial_egg"))
    egg.baseMoneyGenerated = -1
    egg.canGoIntoDebt = true
    end

    do
    local egg = assert(spawnItem(tutEnt, 0,4, "tutorial_egg"))
    egg.grubMoneyCap = 5
    egg.lives = 5
    egg.canItemFloat = true
    egg.repeatActivations = true
    egg.doomCount = 60
    end

    assert(spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot"))
end)
end




do
-- SLOT visuals:
-- DoomCount, lives, money, points, mult, bonus
local TXT = loc("Slots can also have different properties:")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    do local slot = assert(spawnSlot(tutEnt, -4,1, "tutorial_slot"))
    slot.basePointsGenerated = 10 end

    do local slot = assert(spawnSlot(tutEnt, -3,2, "tutorial_slot"))
    slot.doomCount = 3 end

    do local slot = assert(spawnSlot(tutEnt, -1,1, "tutorial_slot"))
    slot.baseMultGenerated = 1 end

    do local slot = assert(spawnSlot(tutEnt, 1,1, "tutorial_slot"))
    slot.lives = 5 end

    do local slot = assert(spawnSlot(tutEnt, 3,2, "tutorial_slot"))
    slot.baseBonusGenerated = 2 end

    do local slot = assert(spawnSlot(tutEnt, 4,1, "tutorial_slot"))
    slot.baseMoneyGenerated = -1
    slot.canGoIntoDebt = true
    end

    do assert(spawnSlot(tutEnt, 0,2, "tutorial_slot")) end

    do
    local slot = assert(spawnSlot(tutEnt, 0,3, "tutorial_slot"))
    slot.basePointsGenerated = 10
    slot.baseBonusGenerated = 2
    slot.baseMoneyGenerated = -1
    slot.repeatActivations = true
    slot.canGoIntoDebt = true
    slot.lives = 5
    slot.doomCount = 50
    end

    assert(spawnSlot(tutEnt, 0,0, "tutorial_pulse_button_slot"))
end)
end




do
-- Target part ONE:

local TXT_UPPER = loc("This item has ROOK-1 targetting.\nTo view the {lootplot.targets:COLOR}target-shape{/lootplot.targets:COLOR}, click on the item")
local TXT_LOWER = loc("If the target is wiggling, a slot will spawn!\nIf it is red cross, the target is invalid.")


tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT_UPPER)

    spawnSlot(tutEnt, -3,1, "tutorial_pulse_button_slot")

    local X,Y = 2,1
    for x=0,1 do
        for y=0,1 do
            spawnSlot(tutEnt, x+X, y+Y, "tutorial_slot")
        end
    end

    assert(spawnItem(tutEnt, X,Y, "tutorial_tombstone"))

    addText(tutEnt, 0,4, TXT_LOWER)
end)
end




do
-- Target part TWO:

local TXT_UPPER = loc("Items can have different target-shapes,\nand different purposes.")

local TXT_LOWER = loc("Have a play around!")


tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT_UPPER)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    assert(spawnItem(tutEnt, -2, 2, "tutorial_tombstone"))

    do
    local e = assert(spawnItem(tutEnt, 0, 3, "golden_compass"))
    lp.setTriggers(e, {"PULSE"})
    end

    assert(spawnItem(tutEnt, 2, 2, "rook_glove"))

    addText(tutEnt, 0,5, TXT_LOWER)
end)
end





-- FOOD ITEMS + Targetting:
do

local TXT_UPPER = loc("And finally, Food items!")
local TXT_LOWER = loc("They activate instantly. Move them to create new slots.")

local TXT_ARROW = "--->"


tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)

    addText(tutEnt, 0,-1, TXT_UPPER)
    addText(tutEnt, 0,0, TXT_LOWER)
    addText(tutEnt, 0,1, TXT_ARROW)

    do
    local X,Y = 1,2
    for x=0,1 do
        for y=0,1 do
            spawnSlot(tutEnt, x+X, y+Y, "tutorial_slot")
        end
    end
    end

    do
    local X,Y = -2,2
    local items = {
        "sausage",
        "dragonfruit",
        "slice_of_cake",
        "dragonfruit",
    }
    local H=1
    for x=0,1 do
        for y=0,H do
            local i = 1+(x*(H+1))+y
            spawnSlot(tutEnt, x+X, y+Y, "null_slot")
            spawnItem(tutEnt, x+X, y+Y, items[i])
        end
    end
    end
end)
end





local TUTORIAL_RUN_REQ_POINTS = {
    40,
    200,
    800,
    2000,
    3500,
    6000,
}

local ROUNDS_PER_LEVEL = 6


do
-- Conclusion
local TXT = loc("Okay! Game time:")
local TXT2 = loc("You have %{rounds} Rounds to make %{points} points...\nYou'll start with a shield!", {
    rounds = ROUNDS_PER_LEVEL,
    points = TUTORIAL_RUN_REQ_POINTS[1]
})

tutorialSections:add(function(tutEnt)
    clearEverythingExceptButtons(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    -- mark as done- this will unlock the starter-item
    lp.metaprogression.setFlag("lootplot.s0:isTutorialCompleted", true)

    addText(tutEnt, 0,1, TXT2)
end)
end



do
-- HANDCRAFTED RUN:

--[[
    This code tries to relocate the doom clock if ther are slot or item below it.
]]
-- Plots to be tested for heurestic search
local SEARCH_SIZE = 2 -- 1 = 3x3, 2 = 5x5, 3 = 7x7, and so on.
local ORDER_SEARCH = lp.targets.KingShape(SEARCH_SIZE)
table.insert(ORDER_SEARCH.relativeCoords, {0, 0}) -- Include center

table.sort(ORDER_SEARCH.relativeCoords, function (a, b)
    local d1 = math.sqrt(a[1] * a[1] + a[2] * a[2])
    local d2 = math.sqrt(b[1] * b[1] + b[2] * b[2])
    return d1 < d2
end)

local function moveClockToClearPosition(ent)
    local ppos = lp.getPos(ent)
    if not ppos then return end
    local plot = ppos:getPlot()

    for _, relpos in ipairs(ORDER_SEARCH.relativeCoords) do
        local px = ent._plotX + relpos[1]
        local py = ent._plotY + relpos[2]

        if px >= 0 and py >= 0 then
            local ppos = plot:getPPos(px, py)

            if not (lp.posToItem(ppos) or lp.posToSlot(ppos)) then
                -- Move it here
                ent.x, ent.y, ent.dimension = ppos:getWorldPos()
                return
            end
        end
    end
end

umg.defineEntityType("lootplot.s0:tutorial_doom_clock", {
    image = "tutorial_doom_clock",
    layer = "world",

    onUpdateServer = function(ent)
        local level = lp.getLevel(ent)
        local currentRequiredPoints = lp.getRequiredPoints(ent)
        local neededRequiredPoints = TUTORIAL_RUN_REQ_POINTS[level] or 40000

        if currentRequiredPoints ~= neededRequiredPoints then
            lp.setAttribute("REQUIRED_POINTS", ent, neededRequiredPoints)
        end
    end,

    onUpdateClient = moveClockToClearPosition
})


local wg = lp.worldgen

tutorialSections:add(function(tutEnt)
    local pos, team = fromMiddle(tutEnt, 0,0), tutEnt.lootplotTeam

    lp.singleplayer.setHUDEnabled(true)

    lp.rawsetAttribute("POINTS", tutEnt, 0)
    lp.setAttribute("NUMBER_OF_ROUNDS", tutEnt, ROUNDS_PER_LEVEL)
    lp.setAttribute("NUMBER_OF_LEVELS", tutEnt, #TUTORIAL_RUN_REQ_POINTS)
    lp.setAttribute("ROUND", tutEnt, 1)
    lp.setAttribute("LEVEL", tutEnt, 1)
    lp.setAttribute("MONEY", tutEnt, 30)

    clearEverything(tutEnt)

    -- spawn doom-clock
    do
    local dclock = server.entities.tutorial_doom_clock()
    local plot = pos:getPlot()
    local midX, midY = pos:getCoords()
    dclock._plotX, dclock._plotY = midX, midY-6
    plot:set(dclock._plotX, dclock._plotY, dclock)
    local wpos = plot:getPPos(dclock._plotX, dclock._plotY)
    dclock.x, dclock.y, dclock.dimension = wpos:getWorldPos()
    end

    -- basic slots
    wg.spawnSlots(pos, server.entities.slot, 3,3, team)

    -- shop:
    wg.spawnSlots(assert(pos:move(-3,0)), server.entities.shop_slot, 1,2, team)
    wg.spawnSlots(assert(pos:move(-3,1)), server.entities.food_shop_slot, 1,1, team)
    wg.spawnSlots(assert(pos:move(-4,0)), server.entities.reroll_button_slot, 1,1, team)

    -- sell slot:
    wg.spawnSlots(assert(pos:move(0,3)), server.entities.sell_slot, 1,1, team)

    -- pulse/level buttons
    lp.forceSpawnSlot(assert(pos:move(-1,-3)), server.entities.pulse_button_slot, team)
    lp.forceSpawnSlot(assert(pos:move(1,-3)), server.entities.tutorial_next_level_button_slot, team)

    lp.forceSpawnItem(assert(pos:move(0,0)), server.entities.wooden_shield, team)

    lp.forceSpawnItem(assert(pos:move(1,1)), server.entities.tutorial_treasure_bar, team)

    -- make basic-slots earn money:
    do
    local slotEnt = lp.posToSlot(assert(pos:move(-1, -1)))
    if slotEnt then lp.modifierBuff(slotEnt, "moneyGenerated", 2) end
    local slotEnt2 = lp.posToSlot(assert(pos:move(1, 0)))
    if slotEnt2 then lp.modifierBuff(slotEnt2, "moneyGenerated", 2) end
    end
end)
end






local function prepareTutorialStage(selfEnt, step)
    lp.rawsetAttribute("POINTS", selfEnt, 0)
    lp.setAttribute("NUMBER_OF_ROUNDS", selfEnt, tutorialSections:size())
    lp.setAttribute("ROUND", selfEnt, step)
    clearEverythingExceptButtons(selfEnt)
    local sect = tutorialSections[step]
    sect(selfEnt)
end


lp.defineSlot(NEXT_TUTORIAL_BUTTON, {
    name = loc("Next Button"),
    activateDescription = loc("Click to go next!"),

    image = "tutorial_button_up",
    activateAnimation = {
        activate = "tutorial_button_down",
        idle = "tutorial_button_up",
        duration = 0.1
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    onActivate = function(selfEnt)
        local len = tutorialSections:size()
        local step = lp.getRound(selfEnt)
        step = math.max(2, math.min(step + 1, len))
        prepareTutorialStage(selfEnt, step)
    end,
})


lp.defineSlot(PREV_TUTORIAL_BUTTON, {
    name = loc("Previous Button"),
    activateDescription = loc("Click to go previous!"),

    scaleX = -1,

    image = "tutorial_button_up",
    activateAnimation = {
        activate = "tutorial_button_down",
        idle = "tutorial_button_up",
        duration = 0.1
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    onActivate = function(selfEnt)
        local step = lp.getRound(selfEnt)
        step = math.max(step - 1, 1)
        prepareTutorialStage(selfEnt, step)
    end,
})





---@param ppos lootplot.PPos
---@param team string
---@param radius integer
local function clearFogInCircle(ppos, team, radius)
    local plot = ppos:getPlot()
    local rsq = radius * radius
    for y = math.floor(-radius), math.ceil(radius) do
        for x = math.floor(-radius), math.ceil(radius) do
            local newPPos = ppos:move(x, y)
            if newPPos then
                local sq = x * x + y * y
                if sq <= rsq then
                    plot:setFogRevealed(newPPos, team, true)
                end
            end
        end
    end
end


local TUT_CAT_ID = "lootplot.s0:tutorial_cat"
lp.worldgen.STARTING_ITEMS:add(TUT_CAT_ID)

local MOVEMENT_TEXT = loc("WASD / Right click to move.\nScroll to zoom.")

lp.defineItem(TUT_CAT_ID, {
    name = loc("Tutorial Cat"),
    description = loc("Provides a short tutorial"),

    image = "tutorial_cat",

    triggers = {"PULSE"},

    canItemFloat = true,

    basePrice = 42, -- answer to the life

    onActivate = function(ent)
        clearEverythingExceptSelf(ent)
        lp.setAttribute("ROUND", ent, 0)

        if lp.singleplayer then
            lp.singleplayer.setHUDEnabled(false)
        end

        do local etype = assert(server.entities[NEXT_TUTORIAL_BUTTON])
        local pos1 = fromMiddle(ent, 1, -3)
        lp.trySpawnSlot(pos1, etype, ent.lootplotTeam) end

        lp.setAttribute("REQUIRED_POINTS", ent, 100)

        addText(ent, 0,2, MOVEMENT_TEXT)

        clearFogInCircle(fromMiddle(ent,0,0), ent.lootplotTeam, 9.8)
    end,
})


