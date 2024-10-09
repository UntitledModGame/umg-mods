local loc = localization.localize

local helper = require("shared.helper")



return lp.defineSlot("lootplot.s0.content:reroll_button_slot", {

    name = loc("Reroll button"),
    description = loc("Click to reroll!"),

    baseMoneyGenerated = -2,

    lootplotProperties = {
        modifiers = {
            -- rerolls cost $1 more every time button activates
            moneyGenerated = function(ent)
                return -(ent.activationCount or 0)
            end
        }
    },

    image = "reroll_button_up",
    activateAnimation = {
        activate = "reroll_button_hold",
        idle = "reroll_button_up",
        duration = 0.25
    },
    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            helper.rerollPlot(ppos:getPlot())
        end
    end,
})
