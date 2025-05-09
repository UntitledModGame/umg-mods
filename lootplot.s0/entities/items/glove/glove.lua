local loc = localization.localize

local function defineGlove(id, name, description, giveShape, rarity)
    return lp.defineItem("lootplot.s0:"..id, {
        image = id,
        name = loc(name),
        activateDescription = loc(description),

        rarity = rarity,

        triggers = {"PULSE"},

        basePrice = 6,
        basePointsGenerated = 25,
        baseMaxActivations = 8,

        shape = lp.targets.UP_SHAPE,

        target = {
            type = "ITEM",
            activate = function(selfEnt, ppos, targetItemEnt)
                if targetItemEnt.shape then
                    lp.targets.setShape(targetItemEnt, giveShape)
                end
            end,
            activateWithNoValidTargets = true
        }
    })
end


defineGlove("up_glove",
    "Up Glove",
    "Set item's targets to UP-1.",
    lp.targets.UpShape(1),
    lp.rarities.RARE
)

defineGlove("knight_glove",
    "Knight Glove",
    "Set item's targets to KNIGHT.",
    lp.targets.KNIGHT_SHAPE,
    lp.rarities.EPIC
)

defineGlove("bishop_glove",
    "Bishop Glove",
    "Set item's targets to BISHOP-2.",
    lp.targets.BishopShape(2),
    lp.rarities.EPIC
)


defineGlove("king_glove",
    "King Glove",
    "Set item's targets to KING-1.",
    lp.targets.KING_SHAPE,
    lp.rarities.RARE
)

defineGlove("rook_glove",
    "Rook Glove",
    "Set item's targets to ROOK-6.",
    lp.targets.RookShape(6),
    lp.rarities.LEGENDARY
)

