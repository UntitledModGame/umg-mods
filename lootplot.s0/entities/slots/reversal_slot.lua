

local loc = localization.localize


lp.defineSlot("lootplot.s0:reversal_button_slot", {
    image = "reversal_button_up",

    name = loc("Reversal Button"),
    activateDescription = loc("Decreases round by 1"),

    activateAnimation = {
        activate = "reversal_button_down",
        idle = "reversal_button_up",
        duration = 0.1
    },

    baseMaxActivations = 20,
    baseMoneyGenerated = -50,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.RARE,

    onDraw = function(ent)
        -- NOTE: this is a bit weird/hacky, 
        -- since we aren't actually drawing anything..
        -- but its "fine"
        if not lp.canActivateEntity(ent) then
            ent.opacity = 0.3
        else
            ent.opacity = 1
        end
    end,

    onActivate = function(ent)
        lp.setRound(ent, lp.getRound(ent) - 1)
    end,
})


