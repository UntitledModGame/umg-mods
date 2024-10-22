
--[[

Contraptions:

"Contraptions" are any entity that is activated via a button.
(Activated via Action-button.)

INSPIRED BY DEREK-YUS BLOG:  
https://derekyu.com/makegames/risk.html



EG:
Reroll-contraption: Rerolls everything in a KING-2 shape. Doomed-6.

Bomb-contraption: Destroys everything in a KING-1 shape. Doomed-2.

Activate-contraption: Activates everything in a ABOVE-1 shape. 4 uses.

Remote-contraption: Rerolls everything in a KING-2 shape. 6 uses.

Nullifying-contraption: disables/enables all target items/slots
NOTE::: This can be used to LOCK the shop!!! Very cool idea!!!

]]


local function defContra(id, etype)
    etype.image = etype.image or id
    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


local ACTIVATE_SELF_BUTTON = {
    text = "Activate!",
    action = function(selfEnt)
        if server then
            lp.tryActivateEntity(selfEnt)
        end
    end
}


local loc = function(x)
    umg.log.warn("FIX ME PLS. PUT PROPER TRANSLATION HERE.")
    return x
end


defContra("old_radio", {
    name = loc("Old Radio"),
    description = loc("Has a button to activate items."),

    triggers = {},

    rarity = lp.rarities.COMMON,

    shape = lp.targets.ABOVE_SHAPE,

    baseMoneyGenerated = -4,
    baseMaxActivations = 4,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryActivateEntity(targetEnt)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})



defContra("dark_radio", {
    name = loc("Dark Radio"),
    description = loc("Has a button to activate an item or a slot,\nthen destroy it."),

    triggers = {},

    rarity = lp.rarities.COMMON,
    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 10,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.queueWithEntity(targetEnt, function ()
                lp.destroy(targetEnt)
            end)
            lp.tryActivateEntity(targetEnt)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})



-- Reroll-contraption: 
-- Rerolls everything in a KING-2 shape. Doomed-6.
defContra("reroll_machine", {
    name = loc("Reroll Machine"),
    description = loc("Has a button to trigger a big reroll."),

    triggers = {},

    rarity = lp.rarities.COMMON,
    shape = lp.targets.KingShape(2),

    baseMoneyGenerated = -4,
    baseMaxActivations = 8,

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})

