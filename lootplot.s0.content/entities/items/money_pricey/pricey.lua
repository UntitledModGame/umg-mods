
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = etype.name or loc(name)
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




defItem("gold_watch", "Gold Watch", {
    triggers = {"PULSE"},

    activateDescription = loc("Increases its price by $1"),

    basePointsGenerated = 10,
    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,

    onActivate = function(ent)
        lp.modifierBuff(ent, "price", 1, ent)
    end,
})



defItem("gold_helmet", "Gold Helmet", {
    activateDescription = loc("Generate points equal to the price of target items."),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 8,
    baseMaxActivations = 5,

    shape = lp.targets.KING_SHAPE,

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



defItem("diamond_ring", "Diamond Ring", {
    triggers = {"LEVEL_UP"},

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



defItem("golden_magnet", "Golden Magnet", {
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



defItem("golden_donut", "Golden Donut", {
    triggers = {"PULSE"},

    activateDescription = loc("Increases target item price by $3"),

    basePrice = 12,
    baseMaxActivations = 2,
    manaCost = 1,
    sticky = true,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "price", 2)
        end
    },

    rarity = lp.rarities.RARE,
})





