

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]


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


