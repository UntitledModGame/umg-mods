

local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")

local consts = require("shared.constants")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end



local function defineDice(id, name, etype)
    etype.name = loc(name)
    etype.rarity = assert(etype.rarity)
    etype.basePrice = etype.basePrice or 6
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0:"..id, etype)
end




--[[
==================================================
DICE ITEMS:
==================================================
]]

-- White Die: 
-- When rerolled, earn $2
defineDice("white_die", "White Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.EPIC,
    baseMoneyGenerated = 2,
    baseMaxActivations = 3,
})



-- Red Die: 
-- When rerolled, gain 0.2 mult
defineDice("red_die", "Red Die", {
    triggers = {"REROLL", "PULSE"},
    activateDescription = loc("When Rerolled, gain {lootplot:POINTS_MULT_COLOR}+0.2 mult"),

    baseMultGenerated = 0.2,
    baseMaxActivations = 10,
    basePrice = 8,

    onTriggered = function(ent, name)
        if name == "REROLL" then
            lp.modifierBuff(ent, "multGenerated", 0.2)
        end
    end,

    rarity = lp.rarities.RARE,
})


defineDice("black_die", "Black Die", {
    triggers = {"REROLL"},
    activateDescription = loc("{lootplot:TRIGGER_COLOR}{wavy}PULSES{/wavy}{/lootplot:TRIGGER_COLOR} item."),

    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 5,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})

do
local CHANCE = 5
local MONEY_EARN = 3

defineDice("green_pencil", "Green Pencil", {
    triggers = {"REROLL"},

    shape = lp.targets.KING_SHAPE,

    description = interp("Has a %{chance}% chance to spawn a {c r=0.6 g=1 b=0.7}REROLL-SLOT{/c} that earns an extra {lootplot:MONEY_COLOR}$%{earn}"){
        chance = CHANCE,
        earn = MONEY_EARN
    },

    baseMaxActivations = 20,
    basePointsGenerated = 40,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos and (lp.SEED:randomMisc()) < (CHANCE/100) then
            local slotEnt = lp.forceSpawnSlot(ppos, server.entities.reroll_button_slot, ent.lootplotTeam)
            if slotEnt then
                lp.modifierBuff(slotEnt, "moneyGenerated", MONEY_EARN, ent)
            end
            lp.destroy(ent)
        end
    end,

    rarity = lp.rarities.EPIC,
})
end



defineDice("quad_dice", "Quad Dice", {
    triggers = {"REROLL"},

    activateDescription = loc("Gives {lootplot:POINTS_COLOR}+3 points{/lootplot:POINTS_COLOR} to all target items"),

    basePrice = 8,
    baseMaxActivations = 10,

    sticky = true,

    shape = lp.targets.RookShape(3),
    target = {
        type = "ITEM",
        activate = function(ent, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 3, ent)
        end
    },

    rarity = lp.rarities.RARE,
})





--[[
====================
GRUBBY SUB-ARCHETYPE:
====================
]]

defineDice("triple_dice", "Triple Dice", {
    triggers = {"REROLL"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 8,
    baseMaxActivations = 6,
    baseMoneyGenerated = 2,

    grubMoneyCap = assert(consts.DEFAULT_GRUB_MONEY_CAP)
})




--[[
========================
GOLDSMITH SUB-ARCHETYPE:
========================
]]

--[[

TODO.

]]

