local CONST = require("client.juice_const")

local LIFETIME = 0.4
local VEL = 200
local ROT = 1

local function makePopup(dvec, txt, color, vel, scale)
    local ent = client.entities.empty()
    ent.x,ent.y, ent.dimension = dvec.x, dvec.y, dvec.dimension
    ent.vx = 0
    ent.vy = vel or -VEL

    ent.color = color

    ent.text = txt

    ent.rot = (love.math.random() * ROT) - ROT/2
    ent.drawDepth = 100
    ent.shadow = {
        offset = 1
    }

    local AMP = 6
    local SCALE = 2
    ent.scale=(1/AMP) * SCALE * (scale or 1)
    ent.bulgeJuice = {freq = 2, amp = AMP, start = love.timer.getTime(), duration = LIFETIME}

    ent.lifetime = LIFETIME
    -- ^^^ delete self after X seconds
end


local function makeAnimation(dvec, frames, color, duration)
    local ent = client.entities.empty()
    ent.x,ent.y, ent.dimension = dvec.x, dvec.y, dvec.dimension

    ent.color = color

    ent.animation = {
        frames = frames,
        tick = "lifetime",
        period = duration
    }

    ent.drawDepth = 100

    ent.lifetime = duration
    -- ^^^ delete self after X seconds   
end


umg.on("lootplot:moneyChanged", function(ent, delta)
    if delta > 0.1 then
        local txt = "$" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.GOLD)
    elseif delta < -0.1 then
        local txt = "-$" .. tostring(math.floor(-delta+0.5))
        makePopup(ent, txt, objects.Color.RED)
    end
end)




umg.on("lootplot:pointsChangedViaCall", function(ent, delta)
    if delta > 0.5 then
        local txt = "+" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.BLUE)
    elseif delta < -0.5 then
        local txt = "-" .. tostring(math.floor(-delta+0.5))
        makePopup(ent, txt, objects.Color.DARK_RED)
    end
end)

umg.on("lootplot:pointsChangedViaBonus", function(ent, delta)
    if delta > 0.5 then
        local txt = "(+" .. tostring(math.floor(delta+0.5)) .. ")"
        makePopup(ent, txt, lp.COLORS.BONUS_COLOR)
    elseif delta < -0.5 then
        local txt = "(-" .. tostring(math.floor(-delta+0.5)) .. ")"
        makePopup(ent, txt, objects.Color.DARK_RED)
    end
end)




umg.on("lootplot:multChanged", function(ent, delta, oldVal, newVal)
    if math.abs(delta) < 0.01 then
        return
    end
    if newVal > 0 then
        local txt = "x" .. tostring(math.floor(newVal*10)/10) .. "!"
        makePopup(ent, txt, lp.COLORS.POINTS_MULT_COLOR)
    elseif newVal < 0 then
        local txt = "-x" .. tostring(math.floor(newVal*10)/10) .. "!"
        makePopup(ent, txt, objects.Color.DARK_RED)
    end
end)

umg.on("lootplot:bonusChanged", function(ent, delta)
    if delta > 0.5 then
        local txt = "+" .. tostring(math.floor(delta+0.5)) .. "!"
        makePopup(ent, txt, lp.COLORS.BONUS_COLOR)
    elseif delta < -0.5 then
        local txt = "-" .. tostring(math.floor(-delta+0.5)) .. "!"
        makePopup(ent, txt, objects.Color.DARK_RED)
    end
end)




local COMBO = localization.newInterpolator("COMBO: %{combo:.0f}")

umg.on("lootplot:comboChanged", function(ent, delta, oldVal, newVal)
    if newVal > 4 and (math.floor(newVal + 0.5) % 5 == 0) then
        local txt = COMBO({combo = newVal})
        local scale = 0.75

        if newVal % CONST.STAND_OUT_COMBO == 0 then
            scale = 2
        end

        makePopup(ent, txt, objects.Color.YELLOW, VEL, scale)
    end
end)

--[[
    mod:  +1 (blue color)
    +mult: + 1 mult  (yellow color)
    x mult:  x2 (red color)
]]

local COLOR_BUFF_DEFAULT = objects.Color(0.98, 0.96, 0.65) -- 5ae6e3

umg.on("lootplot:entityBuffed", function(ent, prop, amount, srcEnt)
    local prefix = ""
    local color = COLOR_BUFF_DEFAULT
    if prop == "moneyGenerated" then
        prefix = "$"
    end

    if prop ~= "pointsGenerated" then
        color = COLOR_BUFF_DEFAULT
    end

    return makePopup(ent, prefix..string.format("%.1f", amount), color, nil, 1.5)
end)




local COMBINE_FRAMES = {
    "combine_item_visual_4",
    "combine_item_visual_3",
    "combine_item_visual_2",
    "combine_item_visual_1",
}
umg.on("lootplot:itemsCombined", function(combinerItem, targetItem)
    makeAnimation(
        targetItem, COMBINE_FRAMES,
        lp.COLORS.COMBINE_COLOR, LIFETIME
    )
end)

