
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


local DESC = loc("Has an activation button.")

local function defContra(id, etype)
    etype.image = etype.image or id
    etype.basePrice = etype.basePrice or 8

    etype.description = DESC

    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


local ACTIVATE_TEXT = loc("Activate!")
local ACTIVATE_TEXT_COST = interp("Activate ($%{cost})")

local ACTIVATE_SELF_BUTTON = {
    text = function(selfEnt)
        if selfEnt.moneyGenerated < 0 then
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



defContra("pulse_tool", {
    name = loc("Pulse Tool"),

    triggers = {},

    rarity = lp.rarities.RARE,

    shape = lp.targets.UP_SHAPE,

    baseMoneyGenerated = -4,
    baseMaxActivations = 4,

    activateDescription = loc("Trigger {lootplot:TRIGGER_COLOR}{wavy}PULSE{/wavy}{/lootplot:TRIGGER_COLOR} on target slot"),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})



defContra("item_destruction_tool", {
    name = loc("Item Destruction Tool"),
    triggers = {},

    rarity = lp.rarities.EPIC,
    shape = lp.targets.UP_SHAPE,

    baseMaxActivations = 10,
    baseMoneyGenerated = -2,

    activateDescription = loc("Activates and destroys target items"),

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

    triggers = {},

    rarity = lp.rarities.EPIC,
    shape = lp.targets.KingShape(2),

    baseMoneyGenerated = -4,
    baseMaxActivations = 4,

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}REROLL{/lootplot:TRIGGER_COLOR} on slot."),

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})



defContra("rotation_tool", {
    name = loc("Rotation Tool"),

    triggers = {},

    rarity = lp.rarities.RARE,
    shape = lp.targets.UpShape(1),

    baseMoneyGenerated = -2,
    baseMaxActivations = 6,

    activateDescription = loc("Rotates target items."),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end
    },

    actionButtons = {ACTIVATE_SELF_BUTTON}
})



defContra("slot_copy_tool", {
    name = loc("Slot Copy Tool"),

    triggers = {},

    rarity = lp.rarities.EPIC,
    shape = lp.targets.UpShape(1),

    activateDescription = loc("Copies a random target slot into this item's position."),

    target = {
        -- this is just for visuals
        type = "SLOT"
    },

    onActivate = function(selfEnt)
        local targs = lp.targets.getTargets(selfEnt) or {}
        if #targs > 0 then
            local ppos = table.random(targs)
            local selfPos = lp.getPos(selfEnt)
            local slotEnt = lp.posToSlot(ppos)
            if selfPos and slotEnt then
                local clone = lp.clone(slotEnt)
                lp.setSlot(selfPos, clone)
                return
            end
        end
    end,

    baseMoneyGenerated = -2,
    baseMaxActivations = 2,

    actionButtons = {ACTIVATE_SELF_BUTTON}
})



--[[

TODO: 

implement mana_tool


]]




--[[
HMM: maybe this shit is too OP?
]]
defContra("round_timer", {
    name = loc("Round timer"),
    activateDescription = loc("Decreases Round by 1"),
    triggers = {},

    doomCount = 1,

    rarity = lp.rarities.EPIC,

    onActivate = function (ent)
        local round = lp.getAttribute("ROUND", ent)
        if round then
            lp.setAttribute("ROUND", ent, round-1)
        end
    end,

    actionButtons = {ACTIVATE_SELF_BUTTON}
})

