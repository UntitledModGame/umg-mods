
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = etype.name or loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end




defItem("golden_watch", "Golden Watch", {
    triggers = {"PULSE"},

    activateDescription = loc("Increases its price by {lootplot:MONEY_COLOR}$4{/lootplot:MONEY_COLOR}"),

    basePointsGenerated = 10,
    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,

    onActivate = function(ent)
        lp.modifierBuff(ent, "price", 4, ent)
    end,
})




---@param arr Entity[]
---@return Entity?
local function findCheapestItem(arr)
    local bestPrice = 0xffffffff
    local bestEnt
    for _,ent in ipairs(arr) do
        if ent.price and (ent.price < bestPrice) then
            bestPrice = ent.price
            bestEnt = ent
        end
    end
    return bestEnt
end


---@param arr Entity[]
---@return Entity?
local function findMostExpensiveItem(arr)
    local bestPrice = -0xffffffff
    local bestEnt
    for _,ent in ipairs(arr) do
        if ent.price and (ent.price > bestPrice) then
            bestPrice = ent.price
            bestEnt = ent
        end
    end
    return bestEnt
end



defItem("golden_magnet", "Golden Magnet", {
    triggers = {"PULSE"},

    activateDescription = loc("Earn money equal to the price of the cheapest target item.\n(Can be negative!)"),

    onActivate = function (ent)
        local items = lp.targets.getConvertedTargets(ent)
        local cheapEnt = findCheapestItem(items)
        if cheapEnt then
            lp.addMoney(ent, cheapEnt.price)
        end
    end,

    basePrice = 8,
    baseMaxActivations = 1,
    sticky = true,

    shape = lp.targets.KingShape(3),
    target = {
        type = "ITEM",
    },

    rarity = lp.rarities.EPIC,
})



defItem("red_magnet", "Red Magnet", {
    triggers = {"PULSE"},

    activateDescription = loc("Adds multiplier equal to the price of the cheapest target item.\n(Can be negative!)"),

    onActivate = function (ent)
        local items = lp.targets.getConvertedTargets(ent)
        local cheapEnt = findCheapestItem(items)
        if cheapEnt then
            lp.addPointsMult(ent, cheapEnt.price)
        end
    end,

    basePrice = 12,
    baseMaxActivations = 2,
    sticky = true,

    shape = lp.targets.KingShape(3),
    target = {
        type = "ITEM",
    },

    rarity = lp.rarities.EPIC,
})



defItem("blue_magnet", "Blue Magnet", {
    activateDescription = loc("Generate points equal to the price of items."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    baseMaxActivations = 5,

    shape = lp.targets.CircleShape(2),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.price
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.addPoints(selfEnt, targetEnt.price)
        end
    }
})





local GOLDEN_DONUT_PRICE_INCREMENT = 4

defItem("golden_donut", "Golden Donut", {
    triggers = {"PULSE"},

    activateDescription = loc("Increases target item price by {lootplot:MONEY_COLOR}$%{buff}", {
        buff = GOLDEN_DONUT_PRICE_INCREMENT
    }),

    unlockAfterWins = 2,

    basePrice = 8,
    baseMaxActivations = 10,
    baseMoneyGenerated = -2,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "price", GOLDEN_DONUT_PRICE_INCREMENT)
        end
    },

    rarity = lp.rarities.RARE,
})




defItem("red_award", "Red Award", {
    triggers = {"PULSE"},

    activateDescription = loc("Gains {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} equal to this item's price"),

    basePrice = 2,

    baseMaxActivations = 8,
    baseMultGenerated = 0,

    lootplotProperties = {
        modifiers = {
            multGenerated = function(ent)
                return ent.price or 0
            end
        }
    },

    rarity = lp.rarities.RARE,
})



