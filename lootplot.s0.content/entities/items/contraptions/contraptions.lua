
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

local loc = localization.localize
local interp = localization.newInterpolator


local function defContra(id, etype)
    etype.image = etype.image or id
    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


local ACTIVATE_TEXT = loc("Activate!")
local ACTIVATE_TEXT_COST = interp("Activate (%{cost})")

local ACTIVATE_SELF_BUTTON = {
    text = function(selfEnt)
        if selfEnt.moneyGenerated > 0 then
            return ACTIVATE_TEXT_COST({
                cost = -selfEnt.moneyGenerated
            })
        else
            return ACTIVATE_TEXT
        end
    end,
    action = function(selfEnt)
        if server then
            lp.tryActivateEntity(selfEnt)
        end
    end
}



defContra("old_radio", {
    name = loc("Old Radio"),
    description = loc("Activates an item."),

    triggers = {},

    rarity = lp.rarities.RARE,

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
    description = loc("Activates and destroys an item."),

    triggers = {},

    rarity = lp.rarities.EPIC,
    shape = lp.targets.ABOVE_SHAPE,

    baseMaxActivations = 10,

    target = {
        type = "ITEM",
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
    description = loc("Triggers a reroll."),

    triggers = {},

    rarity = lp.rarities.EPIC,
    shape = lp.targets.KingShape(2),

    baseMoneyGenerated = -4,
    baseMaxActivations = 4,

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})




--[[
TODO: maybe this shit is too OP?
]]
lp.defineItem("lootplot.s0.content:round_timer", {
    name = loc("Round timer"),
    description = loc("Resets round to 1"),
    triggers = {},

    image = "round_timer",

    baseMoneyGenerated = -30,
    doomCount = 4,

    rarity = lp.rarities.EPIC,

    onActivate = function (ent)
        lp.setAttribute("ROUND", ent, 1)
    end,

    actionButtons = {ACTIVATE_SELF_BUTTON}
})

