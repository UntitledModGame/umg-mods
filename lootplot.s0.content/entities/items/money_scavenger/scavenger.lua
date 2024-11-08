
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id
    etype.grubMoneyCap = etype.grubMoneyCap or 15
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

    grubMoneyCap = 6,

    basePrice = 6,
    baseMoneyGenerated = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3),

    rarity = lp.rarities.UNCOMMON,
})

