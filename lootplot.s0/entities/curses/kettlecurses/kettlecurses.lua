
local lg = love.graphics
local loc = localization.localize



local TEXT_MAX_WIDTH = 200
local function printCentered(text, x, y, rot, sx, sy, oy, kx, ky)
    local r, g, b, a = love.graphics.getColor()
    local f = love.graphics.getFont()
    local txtWidth = f:getWidth(text)
    local ox = 0
    local drawX = x - txtWidth/2
    love.graphics.setColor(0, 0, 0, a)
    for outY = -1, 1 do
        for outX = -1, 1 do
            if not (outX == 0 and outY == 0) then
                love.graphics.printf(text, drawX + outX * sx, y + outY * sy, TEXT_MAX_WIDTH, "left", rot, sx, sy, ox, oy, kx, ky)
            end
        end
    end
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, drawX, y, TEXT_MAX_WIDTH, "left", rot, sx, sy, ox, oy, kx, ky)
end


local function tostr(x)
    return tostring(math.floor(x))
end

local function drawKettleText(ent, x,y,rot, sx,sy,kx,ky)
    local txt, color
    if (ent.moneyGenerated or 0) < 0 then
        txt, color = "$", lp.COLORS.MONEY_COLOR
    elseif (ent.multGenerated or 0) < 0 then
        txt, color = tostr(-ent.multGenerated), lp.COLORS.POINTS_MULT_COLOR
    elseif (ent.bonusGenerated or 0) < 0 then
        txt, color = tostr(-ent.bonusGenerated), lp.COLORS.BONUS_COLOR
    elseif (ent._stealPercentagePoints or 0) > 0 then
        txt, color = tostr(ent._stealPercentagePoints), lp.COLORS.POINTS_COLOR
    else
        return
    end

    lg.setColor(color)
    y = y + (math.sin(love.timer.getTime() * 5)) - 2
    printCentered(txt, x,y, 0, sx,sy, 0, kx,ky)
end


local i = 0

local function defineKettleCurse(comp, val, etype, spawnFilters)
    etype = etype or {}

    etype.isCurse = 1
    etype.curseCount = 1

    etype.name = etype.name or "Kettlecurse"

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    etype.image = etype.image or "kettlecurse"

    etype.onDraw = drawKettleText

    local function scaleWithLevel(ent)
        local lv = ((lp.getLevel(ent) or 1)-1)
        local scale = math.max(1, (lv*lv)/3)
        return scale
    end

    etype.lootplotProperties = {
        multipliers = {
            multGenerated = scaleWithLevel,
            bonusGenerated = scaleWithLevel,
        },
        maximums = {
            multGenerated = 0,
            bonusGenerated = 0,
        }
    }

    etype[comp] = val

    if etype._stealPercentagePoints then
        etype.activateDescription = loc("Reduces {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR} by %{percentage}%", {
            percentage = etype._stealPercentagePoints
        })
    end

    -- NOTE: this is extremely EXTREMELY HACKY.
    -- If we serialize kettlecurse_4, and then delete kettlecurse_3,
    -- then kettlecurse_4's type will be replaced with kettlecurse_5's type next time deser.
    -- oh *well*, its not toooooo big of a deal.
    i = i + 1
    local curseId = "lootplot.s0:kettlecurse_" .. tostring(i)
    lp.defineItem(curseId, etype)

    lp.curses.addSpawnableCurse(curseId, spawnFilters)
end



local function getRerollEtype()
    local REROLL_KETTLECURSE_ETYPE = {
        triggers = {"REROLL"},
        image = "kettlecurse_reroll"
    }
    return REROLL_KETTLECURSE_ETYPE
end


local ABOVE = {"ABOVE"}
local BELOW = {"BELOW"}
local ANY = {}

defineKettleCurse("_stealPercentagePoints", 3, nil, ANY)
defineKettleCurse("_stealPercentagePoints", 5, nil, ANY)
defineKettleCurse("_stealPercentagePoints", 8, nil, ANY)
defineKettleCurse("_stealPercentagePoints", 10, nil, ANY)


defineKettleCurse("baseMoneyGenerated", -1, nil, ANY)
defineKettleCurse("baseMoneyGenerated", -1, getRerollEtype(), ANY)

defineKettleCurse("baseMultGenerated", -0.8, nil, BELOW)
defineKettleCurse("baseMultGenerated", -1.5, nil, BELOW)
defineKettleCurse("baseMultGenerated", -2.0, nil, BELOW)
defineKettleCurse("baseMultGenerated", -0.8, getRerollEtype(), BELOW)
defineKettleCurse("baseMultGenerated", -1.5, getRerollEtype(), BELOW)

defineKettleCurse("baseBonusGenerated", -5, nil, BELOW)
defineKettleCurse("baseBonusGenerated", -10, nil, BELOW)
defineKettleCurse("baseBonusGenerated", -7, getRerollEtype(), BELOW)

