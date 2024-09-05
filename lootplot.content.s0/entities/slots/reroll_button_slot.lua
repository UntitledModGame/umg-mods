return lp.defineSlot("lootplot.content.s0:reroll_button_slot", {

    name = localization.localize("Reroll button"),
    description = localization.localize("Click to reroll!"),

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
        duration = 0.4
    },
    baseMaxActivations = 100,
    triggers = {},
    buttonSlot = true,
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            ppos:getPlot():trigger("REROLL")
        end
    end,
})
