
local loc = localization.localize


umg.defineEntityType("lootplot.main:tutorial_text", {
    onUpdateClient = function(ent)
        local run = lp.main.getRun()
        if run then
            local plot = run:getPlot()
            local pos = plot:getPPos(ent.pposX, ent.pposY):getWorldPos()
            ent.x, ent.y = pos.x, pos.y
        end
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


local function spawnSlot(tutEnt, dx,dy, slotName)
    local ppos = fromMiddle(tutEnt, dx,dy)
    local etype = server.entities[slotName]
    lp.trySpawnSlot(ppos, etype, tutEnt.lootplotTeam)
end


local function spawnItem(tutEnt, dx,dy, itemName)
    local ppos = fromMiddle(tutEnt, dx,dy)
    local etype = server.entities[itemName]
    lp.trySpawnItem(ppos, etype, tutEnt.lootplotTeam)
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
Explain controls
]]
local LEFT = loc("WASD / Right click\nto move around")
local RIGHT = loc("Click to interact\n\nScroll mouse to\nzoom in/out")

local function onActivateControls(e)
    clearEverythingExceptSelf(e)
    addText(e, -3,0, LEFT)
    addText(e, 3,0, RIGHT)
end
tutorialSections:add(onActivateControls)
end



do


local function onActivateControls(e)
    -- setText(e, LEFT, RIGHT)
end
tutorialSections:add(onActivateControls)
end




do
-- Target system
-- (showcase dragonfruit, showcase PIE)
end


do
-- Tier/upgrade system
end


do
-- DoomCount, lives, grubby, floating visuals
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



local TUTORIAL_BUTTON_ID = "lootplot.main:next_tutorial_stage_button"
lp.defineSlot(TUTORIAL_BUTTON_ID, {
    name = loc("Tutorial Button"),
    activateDescription = loc("Click to go next!"),

    image = "tutorial_button_up",
    activateAnimation = {
        activate = "tutorial_button_down",
        idle = "tutorial_button_up",
        duration = 0.25
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,

    init = function(selfEnt)
        selfEnt.currentTutorialStep = 0
    end,

    onActivate = function(selfEnt)
        local step = selfEnt.currentTutorialStep + 1
        selfEnt.currentTutorialStep = step
        clearEverythingExceptSelf(selfEnt)
        local len = tutorialSections:size()
        local i = math.min(len, step)
        local sect = tutorialSections[i]
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


local TUT_CAT_ID = "lootplot.main:tutorial_cat"
lp.worldgen.STARTING_ITEMS:add(TUT_CAT_ID)

local MOVEMENT_TEXT = loc("WASD / Right click to move.\nScroll to zoom.{/wavy}")

lp.defineItem(TUT_CAT_ID, {
    name = loc("Tutorial Cat"),
    description = loc("Provides a short tutorial"),

    image = "tutorial_cat",

    canItemFloat = true,

    basePrice = 42,

    onActivate = function(ent)
        clearEverythingExceptSelf(ent)
        local etype = assert(server.entities[TUTORIAL_BUTTON_ID])
        local pos1 = fromMiddle(ent, 0, -3)
        lp.trySpawnSlot(pos1, etype, ent.lootplotTeam)

        addText(ent, 0,2, MOVEMENT_TEXT)

        clearFogInCircle(fromMiddle(ent,0,0), lp.main.PLAYER_TEAM, 9.8)
    end
})


