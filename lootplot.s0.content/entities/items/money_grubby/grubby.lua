
--[[
===================================================

GRUBBY ITEMS:
Items that work well when low on money.

Uses `grubMoneyCap` component.


NOTE:
our systems support money-caps of any value;
but, in order to keep it simple; we are having only 2 types:
- money-cap

===================================================
]]

local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")

local consts = require("shared.constants")

local MONEY_CAP_LOW = assert(consts.GRUB_MONEY_CAP_LOW)
local MONEY_CAP_MID = assert(consts.GRUB_MONEY_CAP_MID)


local function defItem(id, etype)
    etype.image = etype.image or id
    etype.grubMoneyCap = etype.grubMoneyCap or MONEY_CAP_MID
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end





defItem("the_negotiator", {
    name = loc("The Negotiator"),
    triggers = {},

    basePrice = 10,
    baseMoneyGenerated = 1,
    baseMaxActivations = 50,
    canItemFloat = true,

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    listen = {
        trigger = "BUY",
    }
})



defItem("spare_coins", {
    name = loc("Spare Coins"),
    triggers = {"PULSE"},

    grubMoneyCap = MONEY_CAP_LOW,

    basePrice = 6,
    baseMoneyGenerated = 1,
    baseMaxActivations = 2,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3),

    rarity = lp.rarities.UNCOMMON,
})



defItem("pineapple_ring", {
    name = loc("Pineapple Ring"),

    basePrice = 8,
    doomCount = 8,
    grubMoneyCap = MONEY_CAP_MID,
    canItemFloat = true,
    activateDescription = loc("{lootplot.targets:COLOR}Make all target items $1 cheaper"),

    baseMaxActivations = 8,

    triggers = {},
    listen = {
        trigger = "BUY",
    },
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "price", -1, selfEnt)
        end,
    },

    shape = lp.targets.CircleShape(2),

    rarity = lp.rarities.UNCOMMON,
})


