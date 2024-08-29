

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]
local LIFETIME = 0.4
local ROT = 1

local function makePopup(dvec, txt, color, vel)
    local ent = client.entities.empty()
    ent.x,ent.y, ent.dimension = dvec.x, dvec.y, dvec.dimension
    ent.vx = 0
    ent.vy = vel

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


---@param ent Entity
---@param ppos lootplot.PPos
local function startRound(ent, ppos)
    local plot = ppos:getPlot()

    lp.queue(ppos, function()
        if not umg.exists(ent) then
            -- Next round button is destroyed.
            lp.main.endGame(nil, false)
            return
        end

        -- This will execute LAST.
        plot:foreachLayerEntry(function(ent, ppos, layer)
            lp.reset(ent)
        end)
        lp.addMoney(ent, 8)
    end)

    -- pulse all slots:
    lp.Bufferer()
        :all(plot)
        :to("SLOT") -- ppos-->slot
        :delay(0.2)
        :execute(function(_ppos, slotEnt)
            lp.resetCombo(slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end


lp.defineSlot("lootplot.main:next_round_button_slot", {
    image = "start_button_up",

    name = localization.localize("Next round button"),
    description = localization.localize("Click to go to the next round"),

    activateAnimation = {
        activate = "start_button_hold",
        idle = "start_button_up",
        duration = 0.4
    },

    text = {
        text = "Next Round!",
        oy = -16
    },

    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            startRound(ent, ppos)
        end
    end,
})


if client then

umg.on("lootplot:entityDestroyed", function(ent)
    if ent:type() == "lootplot.main:next_round_button_slot" then
        makePopup(ent, "Never gonna give you up\n", objects.Color.RED, 200)
        makePopup(ent, "\nNever gonna let you down", objects.Color.RED, 200)
    end
end)

end
