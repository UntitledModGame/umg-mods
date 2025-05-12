

local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")

local constants = require("shared.constants")



local function defItem(id, etype)
    etype.image = etype.image or id

    etype.isEntityTypeUnlocked = helper.unlockAfterWins(constants.UNLOCK_AFTER_WINS.SHOPPY)

    return lp.defineItem("lootplot.s0:"..id, etype)
end






defItem("a_big_loan", {
    name = loc("A Big Loan"),

    triggers = {"BUY"},
    activateDescription = loc("Destroys slot and earns money."),

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 20,

    canItemFloat = true,
    rarity = lp.rarities.RARE,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local slotEnt = ppos and lp.posToSlot(ppos)
        if slotEnt then
            -- this will almost certainly be a shop-slot.
            lp.destroy(slotEnt)
        end
    end
})




defItem("a_small_loan", {
    name = loc("A Small Loan"),

    triggers = {"BUY"},

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 20,
    baseMultGenerated = -10,

    canItemFloat = true,
    rarity = lp.rarities.RARE,
})



local MONEY_NEGATIVE = 50
local BACK_LOAN_ROUND = 1

defItem("a_backwards_loan", {
    name = loc("A Backwards Loan"),

    triggers = {"BUY"},

    basePrice = 0,

    activateDescription = loc("Sets money to {lootplot:MONEY_COLOR}-$%{money}{/lootplot:MONEY_COLOR}.\nSets round to %{round}.", {
        money = MONEY_NEGATIVE,
        round = BACK_LOAN_ROUND
    }),

    onActivate = function(ent)
        lp.setMoney(ent, -MONEY_NEGATIVE)
        lp.setRound(ent, BACK_LOAN_ROUND)
    end,

    doomCount = 2,
    baseMaxActivations = 1,

    canItemFloat = true,
    rarity = lp.rarities.LEGENDARY,
})




defItem("a_pointy_loan", {
    name = loc("A Pointy Loan"),

    triggers = {"BUY"},

    lootplotProperties = {
        modifiers = {
            pointsGenerated = function(ent)
                return -(lp.getRequiredPoints(ent) or 0) / 2
            end
        }
    },

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 20,
    basePointsGenerated = 0,

    rarity = lp.rarities.RARE,
})



defItem("a_demonic_loan", {
    name = loc("A Demonic Loan"),

    triggers = {"BUY"},

    activateDescription = loc("Destroys all target items."),

    canItemFloat = true,

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 30,

    shape = lp.targets.QueenShape(4),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})





local BULL_POINTS_BUFF = 20

defItem("bull_helmet", {
    name = loc("Bull Helmet"),

    basePrice = 15,
    baseMaxActivations = 20,

    shape = lp.targets.RookShape(6),

    activateDescription = loc("Adds {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to the purchased item.", {
        buff = BULL_POINTS_BUFF
    }),

    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", BULL_POINTS_BUFF, selfEnt)
        end,
    },

    sticky = true,
    canItemFloat = true,

    rarity = lp.rarities.EPIC,
})





local function defBalloon(id, name, etype)
    etype.name = loc(name)
    etype.shape = etype.shape or lp.targets.CircleShape(2)
    etype.baseMaxActivations = 50
    etype.sticky = true
    if etype.canItemFloat == nil then
        etype.canItemFloat = true
    end
    defItem(id, etype)
end


defBalloon("pink_balloon", "Pink Balloon", {
    activateDescription = loc("Give purchased item {lootplot:LIFE_COLOR}+1 life!{/lootplot:LIFE_COLOR}"),
    rarity = lp.rarities.RARE,

    basePrice = 15,

    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            local lives = targetEnt.lives or 0
            targetEnt.lives = lives + 1
        end,
    }
})



defBalloon("white_balloon", "White Balloon", {
    rarity = lp.rarities.EPIC,

    activateDescription = loc("Makes the purchased item FLOATY."),

    basePrice = 15,
    baseMaxActivations = 20,

    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.canItemFloat = true
            sync.syncComponent(targetEnt, "canItemFloat")
        end,
    },
})





defBalloon("green_balloon", "Green Balloon", {
    activateDescription = loc("Doubles the {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR} of the purchased item."),
    rarity = lp.rarities.RARE,

    basePrice = 15,

    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            local pgen = targetEnt.pointsGenerated or 0
            if pgen ~= 0 then
                lp.modifierBuff(targetEnt, "pointsGenerated", pgen, selfEnt)
            end
        end,
    }
})


defBalloon("rotation_balloon", "Rotation Balloon", {
    rarity = lp.rarities.RARE,

    basePrice = 6,

    activateDescription = loc("Rotates all target items"),

    listen = {
        type = "ITEM",
        trigger = "BUY",
    },
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end
    }
})




defBalloon("blue_balloon", "Blue Balloon", {
    rarity = lp.rarities.RARE,

    baseBonusGenerated = 10,

    basePrice = 10,

    listen = {
        type = "ITEM",
        trigger = "BUY",
    }
})


defBalloon("golden_balloon", "Golden Balloon", {
    activateDescription = loc("If purchased item price is more than {lootplot:MONEY_COLOR}$3,\nEarn $1"),
    rarity = lp.rarities.EPIC,

    basePrice = 10,

    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            if (targetEnt.price or 0) > 3 then
                lp.addMoney(selfEnt, 1)
            end
        end
    }
})




defItem("neko_cat", {
    name = loc("Neko Cat"),
    activateDescription = loc("Activates {lootplot:INFO_COLOR}ALL{/lootplot:INFO_COLOR} target items.\nWorks on all triggers!"),

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    canItemFloat = true,
    sticky = true,

    listen = {
        type = "ITEM",
        trigger = "BUY",
    },

    image = "neko_cat0",
    animation = {
        frames = {"neko_cat0","neko_cat1","neko_cat2","neko_cat1"},
        period = 0.8
    },
    shape = lp.targets.KNIGHT_SHAPE,

    target = {
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryActivateEntity(targetEnt)
        end,
        type = "ITEM"
    }
})



defItem("green_ticket", {
    name = loc("Green Ticket"),

    activateDescription = loc("trigger {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on other slots."),

    basePrice = 10,
    baseMaxActivations = 50,

    sticky = true,
    canItemFloat = true,
    shape = lp.targets.KingShape(2),

    listen = {
        type = "ITEM",
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            local slots = lp.targets.getConvertedTargets(selfEnt)
            local shopSlotThatWasPurchasedFrom = lp.itemToSlot(targetEnt)
            for _,s in ipairs(slots) do
                if s ~= shopSlotThatWasPurchasedFrom then
                    -- dont pulse the slot that we purchased from! Thats bad.
                    lp.tryTriggerEntity("PULSE", s)
                end
            end
        end
    },
    target = {
        type = "SLOT",
    },

    rarity = lp.rarities.RARE,
})




defItem("snake_oil", {
    name = loc("Snake Oil"),

    triggers = {"PULSE", "REROLL"},

    activateDescription = loc("Randomizes item prices between {lootplot:MONEY_COLOR}$0{/lootplot:MONEY_COLOR} and {lootplot:MONEY_COLOR}$15{/lootplot:MONEY_COLOR}"),

    rarity = lp.rarities.RARE,
    canItemFloat = true,
    basePrice = 10,
    baseMaxActivations = 40,

    shape = lp.targets.KingShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local price = lp.SEED:randomMisc(0,15)
            local actualPrice = (targetEnt.price or 0)
            local delta = price - actualPrice
            lp.modifierBuff(targetEnt, "price", delta, selfEnt)
        end
    }
})





defItem("the_negotiator", {
    name = loc("The Negotiator"),

    basePrice = 10,
    baseMoneyGenerated = 1,
    baseBonusGenerated = -3,
    baseMaxActivations = 15,

    canItemFloat = true,

    sticky = true,

    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    listen = {
        type = "ITEM",
        trigger = "BUY",
    }
})




defItem("top_hat", {
    name = loc("Top Hat"),

    triggers = {"PULSE"},

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}BUY{/lootplot:TRIGGER_COLOR} for all target items, (without actually buying them.)"),

    rarity = lp.rarities.LEGENDARY,

    basePrice = 15,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("BUY", targetEnt)
        end
    }
})

