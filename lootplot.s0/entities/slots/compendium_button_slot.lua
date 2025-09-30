


--[[


- Next-round-button (slot)
Progresses to next-round, be activating and resetting the whole slot.


]]

local constants = require("shared.constants")
local helper = require("shared.helper")


local loc = localization.localize


---@param ppos lootplot.PPos
local function resetPlot(ppos)
    local plot = ppos:getPlot()
    lp.queue(ppos, function()
        -- This will execute LAST.
        plot:foreachLayerEntry(function(e, _ppos, layer)
            lp.resetEntity(e)
        end)
    end)
end


do

lp.defineSlot("lootplot.s0:compendium_button_slot", {
    image = "compendium_button_up",

    name = loc("Compendium Button"),
    activateDescription = loc("Click to reset compendium!"),

    activateAnimation = {
        activate = "compendium_button_hold",
        idle = "compendium_button_up",
        duration = 0.1
    },

    baseMaxActivations = 3,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.RARE,

    canActivate = function(ent)
        local round = lp.getRound(ent)
        local numOfRounds = lp.getNumberOfRounds(ent)
        if round <= numOfRounds then
            return true
        end
        return false
    end,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if ppos then
            local plot = ppos:getPlot()
            resetPlot(ppos)

            local i = 0
            plot:foreachSlot(function(e, p)
                if e:type() == "lootplot.s0:compendium_slot" then
                    i = i + 1
                end
            end)

            resetPlot(ppos)
        end
    end,
})

end


