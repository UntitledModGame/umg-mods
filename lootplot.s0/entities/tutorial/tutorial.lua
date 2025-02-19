
local loc = localization.localize


umg.defineEntityType("lootplot.s0:tutorial_text", {
    onUpdateClient = function(ent)
        local run = lp.singleplayer.getRun()
        if run then
            local plot = run:getPlot()
            ent.x, ent.y = plot:getPPos(ent.pposX, ent.pposY):getWorldPos()
        end
    end,
})




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

    onDraw = function(ent, x, y, rot, sx,sy)
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

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
            lp.setPoints(ent, 0)

            local plot = ppos:getPlot()
            lp.Bufferer()
                :all(plot)
                :to("SLOT_OR_ITEM") -- ppos-->slot
                :filter(function(ppos1, e)
                    return lp.hasTrigger(e, "PULSE")
                end)
                :execute(function(_ppos, slotEnt)
                    lp.resetCombo(slotEnt)
                    lp.tryTriggerEntity("PULSE", slotEnt)
                end)

            resetPlot(ent, ppos)
            lp.setPoints(ent, 0)
        end
    end,
})




lp.defineItem("lootplot.s0:tutorial_egg", {
    name = loc("Egg"),
    image = "tutorial_egg",
    triggers = {"PULSE"},
    basePointsGenerated = 1,
})

lp.defineSlot("lootplot.s0:tutorial_slot", {
    name = loc("Slot"),
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
            :execute(function(ppos, ent)
                lp.resetCombo(ent)
                lp.tryTriggerEntity("REROLL", ent)
            end)
    end,
})



---@param tutEnt Entity
local function clearText(tutEnt)
    if tutEnt.tutorialText then
        for _, e in ipairs(tutEnt.tutorialText) do
            if umg.exists(e) then
                e:delete()
            end
        end
        tutEnt.tutorialText = objects.Array()
    end
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
---@return Entity?
local function addText(tutEnt, dx,dy, txt)
    tutEnt.tutorialText = tutEnt.tutorialText or objects.Array()
    local textPos = fromMiddle(tutEnt, dx,dy)
    if not txt:match("%{outline%}") then
        txt = "{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}" .. txt
    end

    local textEnt = server.entities.tutorial_text()
    textEnt.text = txt
    textEnt.pposX, textEnt.pposY = textPos:getCoords()

    tutEnt.tutorialText:add(textEnt)
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


local function clearEverythingExceptSelf(tutEnt)
    local tutPos = assert(lp.getPos(tutEnt))

    tutPos:getPlot():foreachLayerEntry(function (ent, ppos, layer)
        if ent ~= tutEnt then
            ppos:clear(layer)
            ent:delete()
        end
    end)

    clearText(tutEnt)
end




local tutorialSections = objects.Array()



do
--[[
Explain PULSE trigger
]]
local TXT = loc("This is the {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} Button.\nIt will trigger {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} on these eggs!")

tutorialSections:add(function(e)
    clearEverythingExceptSelf(e)
    addText(e, -3,0, TXT)
    spawnSlot(e, -3,3, "tutorial_pulse_button_slot")

    spawnItem(e, 3,1, "tutorial_egg")
    spawnItem(e, 4,2, "tutorial_egg")
    spawnItem(e, 2,0, "tutorial_egg")
    spawnItem(e, 3,4, "tutorial_egg")
    spawnItem(e, 4,0, "tutorial_egg")
end)
end



do
--[[
Explain other triggers.
]]
local TXT = loc("Items can have\ndifferent triggers:")

tutorialSections:add(function(e)
    clearEverythingExceptSelf(e)
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
-- DoomCount, lives, grubby, floating visuals
local TXT = loc("Items can have different properties.\nTake note of the visual indicators!")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptSelf(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    do local egg = assert(spawnItem(tutEnt, -4,1, "tutorial_egg"))
    egg.repeatActivations = true end

    do local egg = assert(spawnItem(tutEnt, -3,2, "tutorial_egg"))
    egg.doomCount = 1 end

    do local egg = assert(spawnItem(tutEnt, -1,1, "tutorial_egg"))
    egg.canItemFloat = true end

    do local egg = assert(spawnItem(tutEnt, 1,1, "tutorial_egg"))
    egg.lives = 5 end

    do local egg = assert(spawnItem(tutEnt, 3,2, "tutorial_egg"))
    egg.grubMoneyCap = 5 end

    do local egg = assert(spawnItem(tutEnt, 4,1, "tutorial_egg"))
    egg.baseMoneyGenerated = -1 end

    do
    local egg = assert(spawnItem(tutEnt, 0,3, "tutorial_egg"))
    egg.grubMoneyCap = 5
    egg.lives = 5
    egg.canItemFloat = true
    egg.repeatActivations = true
    egg.doomCount = 1
    end
end)
end



do
-- Bonus:
local TXT = loc("{lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} will earn extra-points.\nNotice the order!")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptSelf(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    for x=-5, 5 do
        spawnItem(tutEnt, x, 3, "tutorial_egg")
    end
    assert(spawnItem(tutEnt, 0,3, "iron_shovel"))
end)
end


do
-- Negative bonus:
local TXT = loc("{lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} can also be negative!\nWatch out!")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptSelf(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    for x=-3, 3 do
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
local TXT = loc("{lootplot:POINTS_MULT_COLOR}Multiplier{/lootplot:POINTS_MULT_COLOR} will multiply any points earned.\nNotice the order!")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptSelf(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    for x=-5, 5 do
        spawnItem(tutEnt, x, 3, "tutorial_egg")
    end

    local e = assert(spawnItem(tutEnt, 0,3, "iron_spear"))
    e.baseMultGenerated = 2 -- monkeypatch so its clearer.
end)
end





do
-- Target shape:
local TXT = loc("Items can also target other items.\nHave a play around.")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptSelf(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    spawnSlot(tutEnt, 0,1, "tutorial_pulse_button_slot")

    do local e = assert(spawnItem(tutEnt, -2, 3, "dragonfruit"))
    e.doomCount = 99 end

    do local e = assert(spawnItem(tutEnt, 0, 3, "slice_of_cake"))
    e.doomCount = 99 end

    assert(spawnItem(tutEnt, 2, 3, "rook_glove"))
end)
end






do
-- Conclusion
local TXT = loc("Tutorial complete!")
local TXT2 = loc("Press button to restart tutorial.\nEscape to exit.")

tutorialSections:add(function(tutEnt)
    clearEverythingExceptSelf(tutEnt)
    addText(tutEnt, 0,-1, TXT)

    addText(tutEnt, 0,1, TXT2)
end)
end








do
-- Target system
-- (showcase dragonfruit, showcase PIE)
end


do
-- Tier/upgrade system
end

--[[


TODO:
We need to do some proper planning for how the 
round-structure looks.

Perhaps we should delete the DOOM-CLOCK after the 1st explanation...?
And also delete the next-round button?

Create many helper-functions. Be aggressive.
Perhaps we should be more "leniant" with our text positioning too.

Maybe instead of having left/right text,
we should have an array of text entities within the tutorial cat?

DO SOME GOOD PLANNING!!!
USE A WHITEBOARD!!!   Be smart!

]]



local TUTORIAL_BUTTON_ID = "lootplot.s0:next_tutorial_stage_button"
lp.defineSlot(TUTORIAL_BUTTON_ID, {
    name = loc("Tutorial Button"),
    activateDescription = loc("Click to go next!"),

    image = "tutorial_button_up",
    activateAnimation = {
        activate = "tutorial_button_down",
        idle = "tutorial_button_up",
        duration = 0.15
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    init = function(selfEnt)
        selfEnt.currentTutorialStep = 0
    end,

    onActivate = function(selfEnt)
        local len = tutorialSections:size()
        lp.setPoints(selfEnt, 0)
        lp.setAttribute("NUMBER_OF_ROUNDS", selfEnt, len)

        local step = selfEnt.currentTutorialStep + 1
        if step > len then
            step = 1
        end
        lp.setAttribute("ROUND", selfEnt, step)
        selfEnt.currentTutorialStep = step
        clearEverythingExceptSelf(selfEnt)
        local sect = tutorialSections[step]
        sect(selfEnt)
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
        local etype = assert(server.entities[TUTORIAL_BUTTON_ID])
        local pos1 = fromMiddle(ent, 0, -3)
        lp.trySpawnSlot(pos1, etype, ent.lootplotTeam)

        lp.setAttribute("REQUIRED_POINTS", ent, 100)

        addText(ent, 0,2, MOVEMENT_TEXT)

        clearFogInCircle(fromMiddle(ent,0,0), ent.lootplotTeam, 9.8)
    end
})


