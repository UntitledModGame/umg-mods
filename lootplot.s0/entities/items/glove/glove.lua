

local loc = localization.localize
local interp = localization.newInterpolator


local SHAPE_DESC = interp("Set item's targets to {lootplot.targets:COLOR}%{shapeName}{/lootplot.targets:COLOR}.")

local function defineGlove(id, name, giveShape, rarity)
    return lp.defineItem("lootplot.s0:"..id, {
        image = id,
        name = loc(name),
        activateDescription = SHAPE_DESC({
            shapeName = giveShape.name
        }),

        rarity = rarity,

        triggers = {"PULSE"},

        basePrice = 6,
        basePointsGenerated = 100,
        baseMaxActivations = 8,

        doomCount = 10,

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
    lp.targets.UpShape(1),
    lp.rarities.RARE
)

defineGlove("knight_glove",
    "Knight Glove",
    lp.targets.KNIGHT_SHAPE,
    lp.rarities.EPIC
)

defineGlove("bishop_glove",
    "Bishop Glove",
    lp.targets.BishopShape(2),
    lp.rarities.EPIC
)


defineGlove("king_glove",
    "King Glove",
    lp.targets.KING_SHAPE,
    lp.rarities.RARE
)

defineGlove("rook_glove",
    "Rook Glove",
    lp.targets.RookShape(6),
    lp.rarities.LEGENDARY
)

