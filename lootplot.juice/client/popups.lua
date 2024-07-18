
local LIFETIME = 0.4
local VEL = 100

local function makePopup(dvec, txt, color)
    local ent = client.entities.empty()
    ent.x,ent.y, ent.dimension = dvec.x, dvec.y, dvec.dimension
    ent.vx = 0
    ent.vy = -VEL

    ent.color = color

    ent.text = txt

    ent.bulgeJuice = {freq = 2, amp = math.rad(20), start = love.timer.getTime(), duration = 0.4}

    ent.lifetime = LIFETIME
    -- ^^^ delete self after X seconds
end


umg.on("lootplot:moneyChanged", function(ent, delta)
    if delta > 0 then
        local txt = "$" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.GOLD)
    end
end)

umg.on("lootplot:pointsChanged", function(ent, delta)
    if delta > 0 then
        local txt = "+" .. tostring(math.floor(delta+0.5))
        makePopup(ent, txt, objects.Color.RED)
    end
end)
