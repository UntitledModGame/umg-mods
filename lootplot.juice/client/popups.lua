
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

umg.on("lootplot:comboChanged", function(ent, delta, oldVal, newVal)
    if newVal > 4 and (newVal % 5 == 0) then
        local txt = localization.localize("COMBO: ") .. tostring(math.floor(newVal+0.5))
        makePopup(ent, txt, objects.Color.YELLOW, VEL)
    end
end)

umg.on("lootplot:entityDestroyed", function(ent)
    if ent:type() == "lootplot.content.s0:reroll_button_slot" then
        makePopup(ent, "random() = 4", objects.Color.GREEN, VEL)
    end
end)
