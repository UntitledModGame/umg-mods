
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

    tierUpgrade = helper.propertyUpgrade("price", 5, 5),
    rarity = lp.rarities.EPIC,

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



defItem("contract", {
    name = loc("Contract"),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 8,
    tierUpgrade = helper.propertyUpgrade("price", 8, 5),

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

