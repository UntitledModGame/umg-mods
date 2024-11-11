
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


local MONEY_CAP_LOW = 5
local MONEY_CAP_MID = 10


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
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3),

    rarity = lp.rarities.UNCOMMON,
})



defItem("pineapple_ring", {
    name = loc("Pineapple Ring"),

    basePrice = 8,
    doomCount = 8,
    grubMoneyCap = MONEY_CAP_MID,
    canItemFloat = true,
    baseMoneyGenerated = 2,

    triggers = {},
    listen = {
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            local x = math.floor( (targetEnt.price or 2)/2 + 0.5 )
            lp.addMoney(selfEnt, x)
        end,
    },

    shape = lp.targets.CircleShape(2),

    rarity = lp.rarities.UNCOMMON,
})


