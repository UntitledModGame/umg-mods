

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

    basePrice = 0,
    baseMaxActivations = 1,
    baseMoneyGenerated = 20,
    baseMultGenerated = -10,

    canItemFloat = true,
    rarity = lp.rarities.RARE,
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






defItem("bull_helmet", {
    name = loc("Bull Helmet"),

    basePrice = 15,
    baseMaxActivations = 20,

    shape = lp.targets.RookShape(6),

    activateDescription = loc("Adds {lootplot:POINTS_COLOR}+20 points{/lootplot:POINTS_COLOR} to the purchased item."),

    listen = {
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 3, selfEnt)
        end,
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
    activateDescription = loc("Give purchased item {lootplot:LIFE_COLOR}+1 life!{/lootplot:LIFE_COLOR}"),
    rarity = lp.rarities.RARE,

    basePrice = 15,

    listen = {
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
    activateDescription = loc("If purchased item price is more than $3, {lootplot:MONEY_COLOR}earn $1"),
    rarity = lp.rarities.EPIC,

    basePrice = 10,

    listen = {
        trigger = "BUY",
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




defItem("neko_cat", {
    name = loc("Neko Cat"),
    activateDescription = loc("Activates {lootplot:INFO_COLOR}ALL{/lootplot:INFO_COLOR} target items directly."),

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
        type = "ITEM"
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

