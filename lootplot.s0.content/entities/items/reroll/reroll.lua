

local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")

local consts = require("shared.constants")


local function defineDice(id, name, etype)
    etype.name = loc(name)
    etype.rarity = assert(etype.rarity)
    etype.basePrice = 6
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




-- White Die: 
-- When rerolled, earn $2
defineDice("white_die", "White Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.EPIC,
    baseMoneyGenerated = 2,
    baseMaxActivations = 3,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 2, 3)
})



defineDice("black_die", "Black Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 5,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 5, 3),

    target = {
        type = "ITEM",
        description = loc("{lootplot:TRIGGER_COLOR}{wavy}PULSES{/wavy}{/lootplot:TRIGGER_COLOR} item."),
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



--[[
====================
GRUBBY SUB-ARCHETYPE:
====================
]]

defineDice("triple_dice", "Triple Dice", {
    triggers = {"REROLL"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 8,
    baseMaxActivations = 2,
    baseMoneyGenerated = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated",1,3),

    grubMoneyCap = consts.GRUB_MONEY_CAP_LOW
})


local PTS = 20
defineDice("quad_dice", "Quad Dice", {
    triggers = {"REROLL"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 8,
    baseMaxActivations = 10,
    basePointsGenerated = PTS,
    tierUpgrade = helper.propertyUpgrade("pointsGenerated",PTS,3),

    grubMoneyCap = consts.GRUB_MONEY_CAP_LOW,
})



--[[
========================
GOLDSMITH SUB-ARCHETYPE:
========================
]]

--[[

TODO.

]]

