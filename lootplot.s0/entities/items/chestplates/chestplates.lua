

local loc = localization.localize


local CHESTPLATE_SHAPE = lp.targets.HorizontalShape(3)


local function defChestplate(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    etype.shape = etype.shape or CHESTPLATE_SHAPE

    etype.rarity = lp.rarities.RARE
    etype.basePrice = 10

    etype.baseMaxActivations = 4

    return lp.defineItem("lootplot.s0:"..id, etype)
end



