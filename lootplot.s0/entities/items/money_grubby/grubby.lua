
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

    etype.isEntityTypeUnlocked = helper.unlockAfterWins(consts.UNLOCK_AFTER_WINS.GRUBBY)

    return lp.defineItem("lootplot.s0:"..id, etype)
end


local function defGrubby(id, name, etype)
    etype.grubMoneyCap = etype.grubMoneyCap or GRUB_MONEY_CAP
    defItem(id, name, etype)
end



do
GRUB_MULT = 2

defGrubby("hay_bale", "Hay Bale", {
    triggers = {"PULSE"},
    activateDescription = loc("Earns {lootplot:POINTS_MULT_COLOR}+%{mult} mult{/lootplot:POINTS_MULT_COLOR} for each targeted {lootplot:GRUB_COLOR_LIGHT}GRUBBY{/lootplot:GRUB_COLOR_LIGHT} item", {
        mult = GRUB_MULT
    }),

    basePrice = 10,
    baseMaxActivations = 6,

    shape = lp.targets.QueenShape(2),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return targEnt.grubMoneyCap
        end,
        activate = function(selfEnt, ppos, targEnt)
            lp.addPointsMult(selfEnt, GRUB_MULT)
        end
    },

    rarity = lp.rarities.RARE,
})

end




defGrubby("spare_coins", "Spare Coins", {
    triggers = {"PULSE"},

    grubMoneyCap = GRUB_MONEY_CAP,

    basePrice = 6,
    baseMoneyGenerated = 1,
    baseBonusGenerated = 2,
    baseMaxActivations = 6,

    rarity = lp.rarities.UNCOMMON,
})



defGrubby("pineapple_ring", "Pineapple Ring", {
    basePrice = 6,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,
    activateDescription = loc("Make all target items {lootplot:MONEY_COLOR}$2{/lootplot:MONEY_COLOR} cheaper"),

    baseMaxActivations = 8,

    listen = {
        type = "ITEM",
        trigger = "BUY",
    },
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "price", -2, selfEnt)
        end,
    },

    shape = lp.targets.KingShape(1),

    rarity = lp.rarities.UNCOMMON,
})




do
local PRICE_CAP = 6
assert(PRICE_CAP < GRUB_MONEY_CAP, "Erm, this is super unbalanced. Price cap MUST be less than GRUB-CAP")

--[[
Consider this one of the "Staple" items of grubby-builds.
Without this item, grubby-builds are kinda unplayable.
]]
defGrubby("6_cent_ticket", "6 Cent Ticket", {
    basePrice = 2,
    grubMoneyCap = GRUB_MONEY_CAP,
    canItemFloat = true,

    activateDescription = loc("Limit all target item prices to {lootplot:MONEY_COLOR}$%{priceCap}.", {
        priceCap = PRICE_CAP,
    }),

    baseMaxActivations = 40,

    triggers = {"REROLL", "PULSE"},
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            local price = targetEnt.price
            return price and price > PRICE_CAP
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local price = targetEnt.price
            if price and price > PRICE_CAP then
                local delta = targetEnt.price - PRICE_CAP
                lp.modifierBuff(targetEnt, "price", -delta, selfEnt)
            end
        end,
    },

    shape = lp.targets.DownShape(3),

    rarity = lp.rarities.UNCOMMON,
})

end




local function defBasket(id, name, etype)
    etype.shape = etype.shape or lp.targets.UpShape(1)
    etype.init = helper.rotateRandomly

    etype.baseMaxActivations = 4

    etype.rarity = lp.rarities.RARE

    etype.triggers = {"PULSE"}

    defGrubby(id, name, etype)
end


defBasket("basket_of_bonus", "Basket of Bonus", {
    activateDescription = loc("Gives {lootplot:BONUS_COLOR}+1 Bonus{/lootplot:BONUS_COLOR} and {lootplot:GRUB_COLOR_LIGHT}GRUB-%{n}{/lootplot:GRUB_COLOR_LIGHT} to items", {
        n = GRUB_MONEY_CAP
    }),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "bonusGenerated", 1)
            targEnt.grubMoneyCap = GRUB_MONEY_CAP
        end
    }
})




defItem("0_cent_ticket", "0 Cent Ticket", {
    triggers = {"PULSE", "REROLL"},

    activateDescription = loc("Reduces item prices by {lootplot:MONEY_COLOR}$3{/lootplot:MONEY_COLOR}."),

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
        type = "ITEM",
        trigger = "BUY",
    },

    basePrice = 12,
    grubMoneyCap = GRUB_MONEY_CAP,
    baseMoneyGenerated = 6,
    canItemFloat = true,

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.KingShape(3),
})




local BREAD_BUFF = 5

defItem("bread_mace", "Bread Mace", {
    activateDescription = loc("If money is less than {lootplot:MONEY_COLOR}$10{/lootplot:MONEY_COLOR}, permanently gain {lootplot:POINTS_MOD_COLOR}+%{buff} points", {
        buff = BREAD_BUFF
    }),

    onActivate = function(selfEnt)
        if (lp.getMoney(selfEnt) or 0xfff) < 10 then
            lp.modifierBuff(selfEnt, "pointsGenerated", 5, selfEnt)
        end
    end,

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
local WITHDRAW_TEXT = interp("Withdraw $%{amount}")

local WITHDRAW_MONEY_BUTTON = {
    text = function(selfEnt)
        return WITHDRAW_TEXT({
            amount = selfEnt.price
        })
    end,
    action = function(selfEnt)
        if server and selfEnt.price > 0 then
            lp.addMoney(selfEnt, selfEnt.price)
            lp.modifierBuff(selfEnt, "price", -selfEnt.price, selfEnt)
        end
    end,
    color = lp.COLORS.MONEY_COLOR
}

local PRICE_GAIN = 2

defItem("money_sack", "Money Sack", {
    description = loc("Stores money. Can be withdrawn at any time."),

    basePrice = 0,
    grubMoneyCap = GRUB_MONEY_CAP,

    triggers = {"PULSE"},
    baseMoneyGenerated = -PRICE_GAIN,

    onActivate = function(ent)
        lp.modifierBuff(ent, "price", PRICE_GAIN, ent)
    end,

    rarity = lp.rarities.RARE,

    actionButtons = {
        WITHDRAW_MONEY_BUTTON
    }
})

end




defItem("champions_belt", "Champion's Belt", {
    triggers = {"PULSE"},

    activateDescription = loc("Removes {lootplot:GRUB_COLOR_LIGHT}GRUBBY{/lootplot:GRUB_COLOR_LIGHT} from items.\nThen, destroys items."),

    rarity = lp.rarities.EPIC,
    basePrice = 12,

    shape = lp.targets.HorizontalShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            if targEnt.grubMoneyCap then
                targEnt.grubMoneyCap = false
                sync.syncComponent(targEnt, "grubMoneyCap")
            end
            lp.destroy(targEnt)
        end
    },
})






defItem("toolbelt", "Toolbelt", {
    triggers = {"PULSE"},

    activateDescription = loc("Spawns random %{RARE} items, and gives them {lootplot:GRUB_COLOR_LIGHT}GRUB-%{grubCap}", {
        grubCap = GRUB_MONEY_CAP,
        RARE = lp.rarities.RARE.displayString
    }),

    rarity = lp.rarities.RARE,
    basePrice = 8,
    baseMoneyGenerated = -math.floor(GRUB_MONEY_CAP * 0.7),

    shape = lp.targets.DownShape(2),
    target = {
        type = "SLOT_NO_ITEM",
        activate = function(selfEnt, ppos, slotEnt)
            local r = lp.SEED:randomMisc()
            local itemEType
            if r < 0.15 then
                itemEType = lp.rarities.randomItemOfRarity(lp.rarities.EPIC)
            else
                itemEType = lp.rarities.randomItemOfRarity(lp.rarities.RARE)
            end

            local item = itemEType and lp.trySpawnItem(ppos, itemEType, selfEnt.lootplotTeam)
            if item then
                item.grubMoneyCap = GRUB_MONEY_CAP
            end
        end
    },
})



do
local MULT_BUFF = 0.3
local SET_MONEY_TO = 8

defItem("dirty_pillow", "Dirty Pillow", {
    triggers = {"PULSE"},

    activateDescription = loc("Sets money to {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR}.\nGives {lootplot:POINTS_MULT_COLOR}+%{multBuff} mult{/lootplot:POINTS_MULT_COLOR} to dirt-slots", {
        money = SET_MONEY_TO,
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
        type = "SLOT",
        filter = function(selfEnt, ppos, slotEnt)
            return slotEnt:type() == "lootplot.s0:dirt_slot"
        end,
        activate = function(selfEnt, ppos, slotEnt)
            lp.modifierBuff(slotEnt, "multGenerated", MULT_BUFF, selfEnt)
        end
    },
})
end


