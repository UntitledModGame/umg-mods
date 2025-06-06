
--[[

==============================
STARTING CURSES
==============================

these are curses that should spawn at the START of a run.
They usually augment the game a lot, and are more than "an annoyance."

Generally, these curses will force a certain playstyle.

]]

local loc = localization.localize
local interp = localization.newInterpolator

local constants = require("shared.constants")



local function defCurse(id, name, etype)
    etype = etype or {}

    etype.image = id
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    if etype.canItemFloat == nil then
        etype.canItemFloat = true
    end

    lp.defineItem("lootplot.s0:" .. (id), etype)
end


defCurse("aquarium_curse", "Aquarium Curse", {
    description = loc("Whilst this curse exists, {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} cannot go higher than -1."),

    onUpdateServer = function(ent)
        if lp.getPointsBonus(ent) > -1 then
            lp.setPointsBonus(ent, -1)
        end
    end
})



local function spawnCurses(ent, count)
    local ppos = lp.getPos(ent)
    if ppos then
        for _=1, count do
            lp.curses.spawnRandomCurse(ppos:getPlot(), ent.lootplotTeam)
        end
    end
end



do
local DESC = interp("After %{X} activations, delete itself, and spawn %{Y} random curse(s)")

local function drawDelayItemNumber(ent, remaining)
    local dx,dy=0,3 * math.sin(love.timer.getTime())
    local txt = "{outline}" .. tostring(remaining)
    local color = lp.COLORS.INFO_COLOR
    love.graphics.push("all")
    love.graphics.setColor(color)
    local font = love.graphics.getFont()
    local lim = 0xc
    text.printRich(txt, font, ent.x+dx-math.floor(lim/2), ent.y+dy, lim, "center", 0, 1,1)
    love.graphics.pop()
end

defCurse("stone_hand", "Stone Hand", {
    init = function(ent)
        ent.stoneHand_activations = 14
        ent.stoneHand_curses = 2
    end,
    isInvincible = function()
        return true
    end,

    triggers = {"PULSE"},
    activateDescription = function(ent)
        return DESC({
            X = math.max(0, ent.stoneHand_activations - (ent.totalActivationCount or 0)),
            Y = ent.stoneHand_curses
        })
    end,

    onDraw = function(ent)
        local n = math.max(0, ent.stoneHand_activations - (ent.totalActivationCount or 0))
        drawDelayItemNumber(ent, n)
    end,

    onActivate = function (ent)
        if ent.totalActivationCount > ent.stoneHand_activations then
            spawnCurses(ent, ent.stoneHand_curses)
            ent:delete()
        end
    end
})
end


do
local NUM_CURSES = 6
defCurse("trophy_guardian", "Trophy Guardian", {
    description = loc("When the final level is reached, delete self, and spawn %{n} random curses", {
        n = NUM_CURSES
    }),
    triggers = {},

    onUpdateServer = function (ent)
        local level = lp.getLevel(ent)
        local maxLevels = lp.getNumberOfLevels(ent)
        if level == maxLevels then
            spawnCurses(ent, NUM_CURSES)
            ent:delete()
        end
    end,
    isInvincible = function()
        return true
    end
})

end



defCurse("eraser_curse", "Eraser Curse", {
    activateDescription = loc("Destroys all {lootplot:INFO_COLOR}Basic Slots{/lootplot:INFO_COLOR}"),

    triggers = {"PULSE"},

    onActivate = function (ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end
        ppos:getPlot():foreachSlot(function(slotEnt, pp)
            if lp.hasTag(slotEnt, constants.tags.BASIC_SLOT) then
                lp.destroy(slotEnt)
            end
        end)
    end,

    isInvincible = function()
        return true
    end
})



