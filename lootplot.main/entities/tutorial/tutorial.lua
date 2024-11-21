
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

local function makeText(ppos, txt)
    local textEnt = server.entities.tutorial_text()
    textEnt.text = txt
    textEnt.pposX, textEnt.pposY = ppos:getCoords()
end

local function deleteText(ent, key)
    if umg.exists(ent[key]) then
        local textEnt = ent[key]
        textEnt:deepDelete()
    end
end


---@param selfEnt Entity
---@param leftText string
---@param rightText string
local function setText(selfEnt, leftText, rightText)
    deleteText(selfEnt, "leftTutorialText")
    deleteText(selfEnt, "leftTutorialText")
    local ppos = assert(lp.getPos(selfEnt))
    local left = assert(ppos:move(-4,0))
    local right = assert(ppos:move(4,0))

    leftText = "{outline}" .. (leftText or "")
    rightText = "{outline}" .. (rightText or "")

    selfEnt.leftTutorialText = makeText(left, leftText)
    selfEnt.rightTutorialText = makeText(left, leftText)
end




local tutorialSections = objects.Array()



do
--[[
Explain controls
]]
local LEFT = loc("{outline}WASD / Right click\nto move around{/outline}{/wavy}")
local RIGHT = loc("{outline}Click to interact\n\nScroll mouse to\nzoom in/out{/outline}{/wavy}")

local function onActivateControls(e)
    setText(e, LEFT, RIGHT)
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
    setText(e, LEFT, RIGHT)
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


