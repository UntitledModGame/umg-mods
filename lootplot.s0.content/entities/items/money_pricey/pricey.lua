
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = etype.name or loc(name)
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




defItem("gold_watch", "Gold Watch", {
    activateDescription = loc("Increases price by 10%,\n(Max 200)"),

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    onActivate = function(ent)
        local x = ent.price * 0.10
        lp.modifierBuff(ent, "price", x, ent)
    end,

    lootplotProperties = {
        maximums = {
            price = 200
        }
    },
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

