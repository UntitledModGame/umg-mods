
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


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end


local function defGrubby(id, name, etype)
    etype.grubMoneyCap = etype.grubMoneyCap or GRUB_MONEY_CAP
    defItem(id, name, etype)
end







defGrubby("the_negotiator", "The Negotiator", {
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



defGrubby("spare_coins", "Spare Coins", {
    triggers = {"PULSE"},

    grubMoneyCap = GRUB_MONEY_CAP,

    basePrice = 6,
    baseMoneyGenerated = 2,
    baseBonusGenerated = 2,
    baseMaxActivations = 6,

    rarity = lp.rarities.UNCOMMON,
})



defGrubby("pineapple_ring", "Pineapple Ring", {
    basePrice = 8,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,
    activateDescription = loc("Make all target items $2 cheaper"),

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

    rarity = lp.rarities.RARE,
})




do
local PRICE_CAP = GRUB_MONEY_CAP-1

defGrubby("2_cent_ticket", "2 Cent Ticket", {
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


defItem("0_cent_ticket", "0 Cent Ticket", {
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




defItem("3_cent_ticket", "3 Cent Ticket", {
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




local BREAD_BUFF = 5

defItem("bread_mace", "Bread Mace", {
    activateDescription = loc("If money is less than {lootplot:MONEY_COLOR}$10{/lootplot:MONEY_COLOR}, permanently gain {lootplot:POINTS_MOD_COLOR}+%{buff} points", {
        buff = BREAD_BUFF
    }),

    triggers = {"PULSE", "REROLL"},

    basePrice = 10,
    basePointsGenerated = 5,

    rarity = lp.rarities.RARE,
})




defItem("golden_heart", "Golden Heart", {
    triggers = {"PULSE"},

    activateDescription = loc("Gives +1 lives to target item (or slot).\nSets {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} to {lootplot:MONEY_COLOR}$5"),

    doomCount = 6,

    rarity = lp.rarities.RARE,

    shape = lp.targets.UpShape(1),

    basePrice = 4,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
            lp.setMoney(selfEnt, 5)
        end
    },
})




do
local BONUS_BUFF = 2
local MULT_BUFF = 0.1
local SET_MONEY_TO = 8

defItem("toolbelt", "Toolbelt", {
    triggers = {"PULSE"},

    activateDescription = loc("Sets money to {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR}.\n\nGives {lootplot:BONUS_COLOR}+%{bonusBuff} Bonus{/lootplot:BONUS_COLOR} and {lootplot:POINTS_MULT_COLOR}+%{multBuff} mult{/lootplot:POINTS_MULT_COLOR} to dirt-slots", {
        money = SET_MONEY_TO,
        bonusBuff = BONUS_BUFF,
        multBuff = MULT_BUFF
    }),

    onActivate = function(ent)
        lp.setMoney(ent, SET_MONEY_TO)
    end,

    rarity = lp.rarities.RARE,
    basePrice = 8,
    canItemFloat = true,

    shape = lp.targets.KingShape(1),
    target = {
        type = "SLOT_NO_ITEM",
        filter = function(selfEnt, ppos, slotEnt)
            return slotEnt:type() == "lootplot.s0:dirt_slot"
        end,
        activate = function(selfEnt, ppos, slotEnt)
            lp.modifierBuff(slotEnt, "multGenerated", MULT_BUFF, selfEnt)
            lp.modifierBuff(slotEnt, "bonusGenerated", BONUS_BUFF, selfEnt)
        end
    },
})
end

