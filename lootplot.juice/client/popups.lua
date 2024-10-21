
local LIFETIME = 0.4
local VEL = 200
local ROT = 1

local function makePopup(dvec, txt, color, vel)
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
    ent.scale=(1/AMP) * SCALE
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
        speed = duration
    }

    ent.drawDepth = 100

    ent.lifetime = duration
    -- ^^^ delete self after X seconds   
end


umg.on("lootplot:moneyChanged", function(ent, delta)
    if delta > 0.5 then
        local txt = "$" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.GOLD)
    elseif delta < -0.5 then
        local txt = "-$" .. tostring(math.floor(-delta+0.5))
        makePopup(ent, txt, objects.Color.RED)
    end
end)

umg.on("lootplot:pointsChanged", function(ent, delta)
    if delta > 0.5 then
        local txt = "+" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.BLUE)
    elseif delta < -0.5 then
        local txt = "+" .. tostring(math.floor(-delta+0.5))
        makePopup(ent, txt, objects.Color.DARK_RED)
    end
end)

local COMBO = localization.newInterpolator("COMBO: %{combo:.0f}")

umg.on("lootplot:comboChanged", function(ent, delta, oldVal, newVal)
    if newVal > 4 and (math.floor(newVal + 0.5) % 5 == 0) then
        local txt = COMBO({combo = newVal})
        makePopup(ent, txt, objects.Color.YELLOW, VEL)
    end
end)



local LV_UP_TXT = localization.localize("LEVEL UP!")
umg.on("lootplot.tiers:entityUpgraded", function(ent)
    makePopup(ent, LV_UP_TXT, lp.COLORS.COMBINE_COLOR)
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

