

local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end






defItem("a_big_loan", {
    name = loc("A Big Loan"),

    triggers = {"BUY"},
    activateDescription = loc("Destroys slot and earns money."),

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 50,

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
    activateDescription = loc("Permanently gives shop slot {lootplot:BAD_COLOR}-$1 money-earned"),

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 20,

    canItemFloat = true,
    rarity = lp.rarities.RARE,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local slotEnt = ppos and lp.posToSlot(ppos)
        if slotEnt then
            lp.modifierBuff(slotEnt, "moneyGenerated", -1)
        end
    end,
})



defItem("a_pointy_loan", {
    name = loc("A Pointy Loan"),

    triggers = {"BUY"},

    lootplotProperties = {
        multipliers = {
            pointsGenerated = function(ent)
                return lp.getLevel(ent) or 1
            end
        }
    },

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 20,
    basePointsGenerated = -400,

    rarity = lp.rarities.RARE,
})



defItem("a_demonic_loan", {
    name = loc("A Demonic Loan"),

    triggers = {"BUY"},

    activateDescription = loc("Destroys all target slots."),

    canItemFloat = true,

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 100,

    shape = lp.targets.KING_SHAPE,
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})






defItem("bull_helmet", {
    name = loc("Bull Helmet"),

    basePrice = 15,
    baseMaxActivations = 20,

    shape = lp.targets.RookShape(6),

    listen = {
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMultiplierBuff(targetEnt, "pointsGenerated", 3, selfEnt)
        end,
        description = loc("Adds a {lootplot:POINTS_MULT_COLOR}+3{/lootplot:POINTS_MULT_COLOR} points-multiplier to the purchased item."),
    },

    rarity = lp.rarities.EPIC,
})





local function defBalloon(id, name, etype)
    etype.name = loc(name)
    etype.shape = etype.shape or lp.targets.CircleShape(3)
    etype.baseMaxActivations = 50
    if etype.canItemFloat == nil then
        etype.canItemFloat = true
    end
    defItem(id, etype)
end


defBalloon("pink_balloon", "Pink Balloon", {
    rarity = lp.rarities.RARE,

    basePrice = 15,

    listen = {
        trigger = "BUY",
        description = loc("Give purchased item {lootplot:LIFE_COLOR}+1 life!{/lootplot:LIFE_COLOR}"),
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
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.canItemFloat = true
            sync.syncComponent(targetEnt, "canItemFloat")
        end,
    },
})





defBalloon("green_balloon", "Green Balloon", {
    rarity = lp.rarities.RARE,

    basePrice = 15,

    listen = {
        trigger = "BUY",
        description = loc("Give a {lootplot:POINTS_COLOR}2x points multiplier{/lootplot:POINTS_COLOR} to purchased item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.multiplierBuff(targetEnt, "pointsGenerated", 2, selfEnt)
        end,
    }
})


defBalloon("rotation_balloon", "Rotation Balloon", {
    rarity = lp.rarities.RARE,

    basePrice = 6,

    activateDescription = loc("Rotates all target items"),

    listen = {
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

    lootplotProperties = {
        multipliers = {
            pointsGenerated = 6,
        }
    },
    basePointsGenerated = 15,

    basePrice = 10,

    listen = {
        trigger = "BUY",
    }
})


defBalloon("golden_balloon", "Golden Balloon", {
    rarity = lp.rarities.EPIC,

    basePrice = 10,

    listen = {
        trigger = "BUY",
        description = loc("If purchased item price is more than $3, {lootplot:MONEY_COLOR}earn $1"),
        activate = function(selfEnt, ppos, targetEnt)
            if (targetEnt.price or 0) > 3 then
                lp.addMoney(selfEnt, 1)
            end
        end
    }
})


defBalloon("mana_balloon", "Mana Balloon", {
    rarity = lp.rarities.RARE,

    basePrice = 15,

    manaCost = -1,

    listen = {
        trigger = "BUY",
    }
})




helper.defineDelayItem("key_balloon", "Key Balloon", {
    --[[
    After X activations, turn into a floating key

    TODO:
    This is TRASH! We can do way better than this, man
    ]]
    listen = {
        trigger = "BUY",
    },

    shape = lp.targets.CircleShape(3),
    baseMaxActivations = 50,
    canItemFloat = true,

    delayAction = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end
        lp.trySpawnSlot(ppos, server.entities.steel_slot, ent.lootplotTeam)
        local keyEnt = lp.forceSpawnItem(ppos, server.entities.key, ent.lootplotTeam)
        if keyEnt then
            keyEnt.canItemFloat = true
        end
    end,
    delayCount = 8,
    delayDescription = "Spawns a {lootplot:INFO_COLOR}STEEL-SLOT{/lootplot:INFO_COLOR}, and a {lootplot:INFO_COLOR}FLOATY-KEY{/lootplot:INFO_COLOR}!",

    basePrice = 8,

    rarity = lp.rarities.RARE,
})



defItem("neko_cat", {
    name = loc("Neko Cat"),

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    canItemFloat = true,


    listen = {
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
        description = loc("Activates {lootplot:INFO_COLOR}ALL{/lootplot:INFO_COLOR} target items directly."),
        type = "ITEM"
    }
})




defItem("top_hat", {
    name = loc("Top Hat"),
    description = loc("Triggers {lootplot:TRIGGER_COLOR}BUY{/lootplot:TRIGGER_COLOR}for all target items, (without actually buying them.)"),

    rarity = lp.rarities.LEGENDARY,

    basePrice = 15,

    shape = lp.targets.KNIGHT_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("BUY", targetEnt)
        end
    }
})

