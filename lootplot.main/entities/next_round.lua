

--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]

local function resetPlot(plot)
    plot:foreachItem(function(ent, _ppos)
        lp.reset(ent)
    end)
    plot:foreachSlot(function(ent, _ppos)
        lp.reset(ent)
    end)
    plot:trigger("RESET")
end


---@param ent Entity
---@param ppos lootplot.PPos
local function startRound(ent, ppos)
    local plot = ppos:getPlot()

    lp.queue(ppos, function()
        -- This will execute LAST.
        plot:reset()
        resetPlot(plot)
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
    image = "button_up",
    activateAnimation = {
        activate = "button_hold",
        idle = "button_up",
        duration = 0.4
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


