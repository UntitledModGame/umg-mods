

local loc = localization.localize



lp.defineSlot("lootplot.s0:tax_button_slot", {
    image = "tax_button_up",

    name = loc("Tax Button"),
    activateDescription = loc("Increases round by 1"),

    activateAnimation = {
        activate = "tax_button_hold",
        idle = "tax_button_up",
        duration = 0.1
    },

    baseMaxActivations = 20,
    baseMoneyGenerated = 30,

    triggers = {},
    buttonSlot = true,

    rarity = lp.rarities.EPIC,

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

    canActivate = function(ent)
        local round = lp.getRound(ent)
        local maxRounds = lp.getNumberOfRounds(ent)
        return round < maxRounds
    end,

    onActivate = function(ent)
        lp.setRound(ent, lp.getRound(ent) + 1)
    end,
})


