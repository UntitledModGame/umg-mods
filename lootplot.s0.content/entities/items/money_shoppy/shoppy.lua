

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

    basePrice = 100,
    baseMaxActivations = 1,
    baseMoneyGenerated = 200,

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



defItem("a_pointy_loan", {
    name = loc("A Pointy Loan"),

    triggers = {"BUY"},
    activateDescription = loc("Destroys slot and earns money."),

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




defItem("bull_helmet", {
    name = loc("Bull Helmet"),

    triggers = {},

    basePrice = 15,
    baseMaxActivations = 20,

    shape = lp.targets.RookShape(6),

    listen = {
        trigger = "BUY",
        activate = function(selfEnt, ppos, targetEnt)
            lp.multiplierBuff(targetEnt, "pointsGenerated", 3, selfEnt)
        end,
        description = loc("Adds a {lootplot:POINTS_MULT_COLOR}3x{/lootplot:POINTS_MULT_COLOR} points-multiplier to the purchased item."),
    },

    rarity = lp.rarities.EPIC,
})


