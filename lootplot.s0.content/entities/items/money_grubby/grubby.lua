
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

local GRUB_MONEY_CAP = assert(consts.DEFAULT_GRUB_MONEY_CAP)


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end
local function defGrubby(id, etype)
    etype.grubMoneyCap = etype.grubMoneyCap or GRUB_MONEY_CAP
    defItem(id, etype)
end







defGrubby("the_negotiator", {
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



defGrubby("spare_coins", {
    name = loc("Spare Coins"),
    triggers = {"PULSE"},

    grubMoneyCap = GRUB_MONEY_CAP,

    basePrice = 6,
    baseMoneyGenerated = 1,
    baseMaxActivations = 2,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3),

    rarity = lp.rarities.UNCOMMON,
})



defGrubby("pineapple_ring", {
    name = loc("Pineapple Ring"),

    basePrice = 8,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,
    activateDescription = loc("{lootplot.targets:COLOR}Make all target items $2 cheaper"),

    baseMaxActivations = 8,

    triggers = {},
    listen = {
        trigger = "BUY",
    },
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "price", -2, selfEnt)
        end,
    },

    shape = lp.targets.CircleShape(2),

    rarity = lp.rarities.UNCOMMON,
})




do
local CENT_REQ = GRUB_MONEY_CAP-1
local PRICE_SET = 4

defGrubby("2_cent_ticket", {
    name = loc("2 Cent Ticket"),

    basePrice = 2,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,

    baseMaxActivations = 20,

    triggers = {"REROLL", "PULSE"},
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local price = targetEnt.price
            if price and price > CENT_REQ then
                local delta = targetEnt.price - PRICE_SET
                lp.modifierBuff(targetEnt, "price", -delta, selfEnt)
            end
        end,
        description = interp("If item price more than $%{price}, set item's price to $%{priceSet}."){
            price = CENT_REQ,
            priceSet = PRICE_SET
        }
    },

    shape = lp.targets.CircleShape(3),

    rarity = lp.rarities.RARE,
})

end




defItem("grub_converter", {
    name = loc("Grub Converter"),
    triggers = {"PULSE"},

    basePrice = 6,
    baseMaxActivations = 1,

    shape = lp.targets.UP_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            if not targetEnt.grubMoneyCap then
                lp.multiplierBuff(targetEnt, "pointsGenerated", 4)
                targetEnt.grubMoneyCap = GRUB_MONEY_CAP
            end
        end,
        description = loc("If target item is {lootplot:GRUB_COLOR}NOT grubby{/lootplot:GRUB_COLOR}, give it a {lootplot:POINTS_MULT_COLOR}x4 points-multiplier{/lootplot:POINTS_MULT_COLOR}, and give it {lootplot:GRUB_COLOR}GRUB-10.")
    },

    rarity = lp.rarities.EPIC,
})

