local loc = localization.localize

local function defineGlove(id, name, description, giveShape, rarity)
    return lp.defineItem("lootplot.s0.content:"..id, {
        image = id,
        name = loc(name),
        activateDescription = loc(description),

        rarity = rarity,

        triggers = {"PULSE"},

        basePrice = 8,

        shape = lp.targets.UP_SHAPE,

        target = {
            type = "ITEM",
            activate = function(selfEnt, ppos, targetItemEnt)
                if targetItemEnt.shape then
                    lp.targets.setShape(targetItemEnt, giveShape)
                end
            end
        }
    })
end



defineGlove("knight_glove",
    "Knight Glove",
    "Set target item's shape to KNIGHT.",
    lp.targets.KNIGHT_SHAPE,
    lp.rarities.RARE
)

defineGlove("king_glove",
    "King Glove",
    "Set target item's shape to KING-1.",
    lp.targets.KING_SHAPE,
    lp.rarities.EPIC
)

defineGlove("rook_glove",
    "Rook Glove",
    "Set target item's shape to ROOK-10.",
    lp.targets.RookShape(10),
    lp.rarities.LEGENDARY
)

