
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




defItem("gold_watch", {
    name = loc("Gold Watch"),
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



defItem("gold_helmet", {
    name = loc("Gold Helmet"),

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},

    basePrice = 8,
    baseMaxActivations = 5,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Generate points equal to the price of item."),
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.price
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.addPoints(selfEnt, targetEnt.price)
        end
    }
})

