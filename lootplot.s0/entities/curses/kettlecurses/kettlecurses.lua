
local lg = love.graphics



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



local function drawKettleText(ent, x,y,rot, sx,sy,kx,ky)
    local txt, color
    if ent.moneyGenerated < 0 then
        txt, color = "$", lp.COLORS.MONEY_COLOR
    elseif ent.multGenerated < 0 then
        txt, color = tostring(-ent.multGenerated), lp.COLORS.POINTS_MULT_COLOR
    elseif ent.bonusGenerated < 0 then
        txt, color = tostring(-ent.bonusGenerated), lp.COLORS.BONUS_COLOR
    elseif ent.pointsGenerated < 0 then
        txt, color = tostring(-ent.pointsGenerated), lp.COLORS.POINTS_COLOR
    else
        return
    end

    lg.setColor(color)
    y = y + (math.sin(love.timer.getTime() * 5)) - 2
    printCentered(txt, x,y, 0, sx,sy, 0, kx,ky)
end


local function defineKettleCurse(property, propChange, etype)
    etype = etype or {}

    etype.name = etype.name or "Kettlecurse"

    etype.triggers = etype.triggers or {"PULSE"}
    etype.rarity = etype.rarity or lp.rarities.CURSE_1
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    etype.image = etype.image or "kettlecurse"

    etype.onDraw = drawKettleText

    local basePropName = assert(properties.getBase(property))
    etype[basePropName] = propChange

    lp.defineItem("lootplot.s0:kettlecurse_" .. property .. "_" .. tostring(propChange), etype)
end



defineKettleCurse("pointsGenerated", -10)
defineKettleCurse("pointsGenerated", -20)

defineKettleCurse("moneyGenerated", -1)

defineKettleCurse("multGenerated", -0.3)
defineKettleCurse("multGenerated", -0.5)
defineKettleCurse("multGenerated", -0.9)

defineKettleCurse("bonusGenerated", -2)
defineKettleCurse("bonusGenerated", -5)
