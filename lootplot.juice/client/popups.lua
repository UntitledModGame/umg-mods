
local LIFETIME = 0.4
local VEL = 200
local ROT = 1

local function makePopup(dvec, txt, color, velY)
    local ent = client.entities.empty()
    ent.x,ent.y, ent.dimension = dvec.x, dvec.y, dvec.dimension
    ent.vx = 0
    ent.vy = velY

    ent.color = color

    ent.text = txt
    ent.scale=0.75

    ent.rot = (love.math.random() * ROT) - ROT/2
    ent.drawDepth = 100
    ent.shadow = {
        offset = 2
    }

    ent.bulgeJuice = {freq = 2, amp = math.rad(20), start = love.timer.getTime(), duration = 0.4}

    ent.lifetime = LIFETIME
    -- ^^^ delete self after X seconds
end


umg.on("lootplot:moneyChanged", function(ent, delta)
    if delta > 0 then
        local txt = "$"
        makePopup(ent, txt, objects.Color.GOLD, VEL)
    end
end)

umg.on("lootplot:pointsChanged", function(ent, delta)
    if delta > 0 then
        local txt = "+" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.RED, -VEL)
    end
end)
