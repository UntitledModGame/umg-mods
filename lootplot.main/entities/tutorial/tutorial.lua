
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

---@param tutEnt Entity
---@param dx number
---@param dy number
---@param txt string
local function addText(tutEnt, dx,dy, txt)
    tutEnt.tutorialText = tutEnt.tutorialText or objects.Array()
    local ppos = assert(lp.getPos(tutEnt))
    local midPos = ppos:getPlot():getCenterPPos()

    local textPos = assert(midPos:move(dx,dy))

    txt = "{outline}" .. txt

    local textEnt = server.entities.tutorial_text()
    textEnt.text = txt
    textEnt.pposX, textEnt.pposY = textPos:getCoords()

    tutEnt.tutorialText:add(textEnt)
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
local LEFT = loc("{outline}WASD / Right click\nto move around{/outline}{/wavy}")
local RIGHT = loc("{outline}Click to interact\n\nScroll mouse to\nzoom in/out{/outline}{/wavy}")

local function onActivateControls(e)
    clearEverythingExceptSelf(e)
    addText(e, -5,0, LEFT)
    addText(e, 5,0, RIGHT)
end
tutorialSections:add(onActivateControls)
end



do
--[[
Explain goal of the game:

You have 6 rounds to earn 150 points.
Fail that, and you lose!
]]
local LEFT = loc("")
local RIGHT = loc("")

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


lp.defineItem("lootplot.main:tutorial_cat", {
    name = loc("Tutorial Cat"),
    description = loc("Provides a short tutorial for lootplot"),

    basePointsGenerated = 5000,

    init = function(selfEnt)
        selfEnt.currentTutorialStep = 0
    end,

    onActivate = function(ent)
        
    end
})


