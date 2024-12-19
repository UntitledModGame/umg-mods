
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

    rarity = lp.rarities.UNCOMMON,
})



defGrubby("pineapple_ring", {
    name = loc("Pineapple Ring"),

    basePrice = 8,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,
    activateDescription = loc("{lootplot.targets:COLOR}Make all target items $2 cheaper"),

    baseMaxActivations = 8,

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
local PRICE_CAP = GRUB_MONEY_CAP-1

defGrubby("2_cent_ticket", {
    name = loc("2 Cent Ticket"),

    basePrice = 2,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,

    activateDescription = loc("Limit all target item prices to {lootplot:MONEY_COLOR}$%{priceCap}.", {
        priceCap = PRICE_CAP,
    }),

    baseMaxActivations = 20,

    triggers = {"REROLL", "PULSE"},
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local price = targetEnt.price
            if price and price > PRICE_CAP then
                local delta = targetEnt.price - PRICE_CAP
                lp.modifierBuff(targetEnt, "price", -delta, selfEnt)
            end
        end,
    },

    shape = lp.targets.CircleShape(3),

    rarity = lp.rarities.RARE,
})

end


defItem("0_cent_ticket", {
    name = loc("0 Cent Ticket"),
    triggers = {"PULSE", "REROLL"},

    activateDescription = loc("Reduces all target item prices by {lootplot:MONEY_COLOR}$3{/lootplot:MONEY_COLOR}."),

    basePrice = 6,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,

    rarity = lp.rarities.RARE,

    shape = lp.targets.DownShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local price = targetEnt.price
            if price then
                lp.modifierBuff(targetEnt, "price", -3, selfEnt)
            end
        end
    },
})




defItem("3_cent_ticket", {
    name = loc("3 Cent Ticket"),

    listen = {
        trigger = "BUY",
    },

    basePrice = 12,
    grubMoneyCap = 5,
    baseMoneyGenerated = 5,
    canItemFloat = true,

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.KingShape(3),
})





--[[
TODO:
this really isn't a grubby-item....
idk why its here...?
]]
defItem("dirt_maker", {
    name = loc("Dirt Maker"),
    triggers = {"PULSE"},

    basePrice = 10,
    baseMaxActivations = 10,

    activateDescription = loc("Spawns dirt slots."),

    shape = lp.targets.UpShape(1),

    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnSlot(ppos, server.entities.dirt_slot, selfEnt.lootplotTeam)
        end,
    },

    rarity = lp.rarities.EPIC,
})



defItem("golden_heart", {
    name = loc("Golden Heart"),
    triggers = {"PULSE"},

    activateDescription = loc("Gives +1 lives to target item (or slot).\nSets {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} to {lootplot:BAD_COLOR}$-1"),

    doomCount = 6,

    rarity = lp.rarities.RARE,

    shape = lp.targets.UpShape(1),

    basePrice = 4,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
            lp.setMoney(selfEnt, -1)
        end
    },
})

