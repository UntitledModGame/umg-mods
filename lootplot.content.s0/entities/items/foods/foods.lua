

local loc = localization.localize



lp.defineItem("lootplot.content.s0:blueberry", {
    image = "blueberry",

    name = loc("Blueberry"),
    description = loc("A Blue berry!"),

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Adds +1 of generated point to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        return lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
    end
})


lp.defineItem("lootplot.content.s0:lychee", {
    image = "lychee",

    name = loc("Lychee"),

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Gives +1 activation to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        lp.modifierBuff(targetEnt, "maxActivations", 1, selfEnt)
    end
})

lp.defineItem("lootplot.content.s0:apple", {
    image = "apple",
    name = loc("Apple"),
    doomCount = 1,

    targetType = "SLOT",
    targetShape = lp.targets.BELOW_SHAPE,
    targetActivationDescription = loc("Transforms into a GOLD or DIAMOND slot."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        -- TODO: Better randomizer, I think?
        local newSlotType = math.random(0, 1) == 0 and
            "lootplot.content.s0:gold_slot" or
            "lootplot.content.s0:diamond_slot"
        local etype = server.entities[newSlotType]
        if etype then
            lp.forceSpawnSlot(ppos, etype)
        end
    end
})

lp.defineItem("lootplot.content.s0:gapple", {
    image = "gapple",
    name = loc("Gapple"),
    doomCount = 1,

    targetType = "NO_SLOT",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = loc("Clones the current slot the item is in."),
    targetActivate = function(selfEnt, ppos)
        local etype = server.entities[selfEnt:ent()]
        if etype then
            lp.forceSpawnSlot(ppos, etype)
        end
    end
})

lp.defineItem("lootplot.content.s0:magic_radish", {
    image = "magic_radish",
    name = loc("Magic Radish"),

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Transform into above item."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local selfPPos = lp.getPos(selfEnt)

        if selfPPos then
            lp.forceSpawnItem(selfPPos, server.entities[targetEnt:type()])
        end
    end
})

lp.defineItem("lootplot.content.s0:glass_bottle", {
    image = "glass_bottle",
    name = loc("Glass Bottle"),
    doomCount = 1,

    targetType = "NO_SLOT",
    targetShape = lp.targets.UnionShape(
        lp.targets.PlusShape(4),
        lp.targets.CrossShape(4),
        "QUEEN-4"
    ),
    targetActivationDescription = loc("spawn Glass Slots."),
    targetActivate = function(selfEnt, ppos)
        local etype = server.entities["lootplot.content.s0:glass_slot"]
        if etype then
            lp.forceSpawnSlot(ppos, etype)
        end
    end
})
