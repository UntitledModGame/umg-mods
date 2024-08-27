

local loc = localization.localize


local function defineFood(entName, etype)
    etype.doomCount = etype.doomCount or 1
end


defineFood("lootplot.content.s0:blueberry", {
    image = "blueberry",

    name = loc("Blueberry"),

    rarity = lp.rarities.EPIC,
    minimumLevelToSpawn = 6,

    baseTraits = {},

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("{lp_targetColor}Adds 2 Doom-count to item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        if targetEnt.doomCount then
            targetEnt.doomCount = targetEnt.doomCount + 2
        end
    end
})


defineFood("lootplot.content.s0:lychee", {
    image = "lychee",

    name = loc("Lychee"),

    baseTraits = {},

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 6,

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("{lp_targetColor}Gives +5 max-activations to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        lp.modifierBuff(targetEnt, "maxActivations", 5, selfEnt)
    end
})


defineFood("lootplot.content.s0:golden_apple", {
    image = "golden_apple",
    name = loc("Golden Apple"),

    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 3,

    targetType = "SLOT",
    targetShape = lp.targets.ON_SHAPE,
    targetActivationDescription = loc("Transforms into a GOLD slot."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        -- "lootplot.content.s0:diamond_slot"
        local etype = server.entities["lootplot.content.s0:gold_slot" ]
        if etype then
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})


defineFood("lootplot.content.s0:diamond_apple", {
    image = "diamond_apple",
    name = loc("Diamond Apple"),

    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 3,

    targetType = "SLOT",
    targetShape = lp.targets.ON_SHAPE,
    targetActivationDescription = loc("Transforms into a DIAMOND slot."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local etype = server.entities["lootplot.content.s0:diamond_slot"]
        if etype then
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})

defineFood("lootplot.content.s0:super_apple", {
    image = "apple",
    name = loc("Super Apple"),

    rarity = lp.rarities.EPIC,
    minimumLevelToSpawn = 6,

    targetType = "NO_SLOT",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = loc("Clones the current slot the item is in."),
    targetActivate = function(selfEnt, ppos, ent)
        local slotEnt = lp.itemToSlot(selfEnt)
        local etype
        if slotEnt then
            etype = slotEnt:getEntityType()
        end
        if etype then
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})



defineFood("lootplot.content.s0:magic_radish", {
    image = "magic_radish",
    name = loc("Magic Radish"),

    minimumLevelToSpawn = 6,
    rarity = lp.rarities.EPIC,

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Transforms into random target item."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local selfPPos = lp.getPos(selfEnt)

        if selfPPos then
            lp.forceSpawnItem(selfPPos, server.entities[targetEnt:type()], selfEnt.lootplotTeam)
        end
    end
})





defineFood("lootplot.content.s0:glass_bottle", {
    image = "glass_bottle",
    name = loc("Glass Bottle"),

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 2,

    targetType = "NO_SLOT",
    targetShape = lp.targets.QueenShape(4),

    targetActivationDescription = loc("Spawns glass slots"),

    targetActivate = function(selfEnt, ppos)
        local etype = server.entities["lootplot.content.s0:glass_slot"]
        if etype then
            lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})

defineFood("lootplot.content.s0:glass_tube", {
    image = "glass_tube",

    name = localization.localize("Glass tube"),
    targetActivationDescription = loc("Spawns glass slots"),

    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,

    targetType = "NO_SLOT",
    targetShape = lp.targets.CrossShape(4),

    targetActivate = function(selfEnt, ppos)
        local etype = server.entities["lootplot.content.s0:glass_slot"]
        if etype then
            lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})





defineFood("lootplot.content.s0:pomegranate", {
    image = "pomegranate",

    name = localization.localize("pomegranate"),
    targetActivationDescription = localization.localize("Generates normal slots"),

    rarity = lp.rarities.UNCOMMON,

    baseBuyPrice = 4,
    baseTraits = {},

    targetType = "NO_SLOT",
    targetShape = lp.targets.KING_SHAPE,

    targetActivate = function(ent, ppos, targetEnt)
        lp.forceSpawnSlot(ppos, server.entities.slot, ent.lootplotTeam)
    end,
})


defineFood("lootplot.content.s0:dragonfruit", {
    image = "dragonfruit",

    name = localization.localize("dragonfruit"),
    targetActivationDescription = localization.localize("Generates normal slots"),

    rarity = lp.rarities.UNCOMMON,

    baseBuyPrice = 4,
    baseTraits = {},

    targetType = "NO_SLOT",
    targetShape = lp.targets.PlusShape(2),

    targetActivate = function(ent, ppos, targetEnt)
        lp.forceSpawnSlot(ppos, server.entities.slot, ent.lootplotTeam)
    end,
})



defineFood("lootplot.content.s0:soy_sauce", {
    image = "soy_sauce",

    name = localization.localize("soy sauce"),
    targetActivationDescription = localization.localize("Generates doomed-4 slots"),

    rarity = lp.rarities.UNCOMMON,

    baseBuyPrice = 4,
    baseTraits = {},

    targetType = "NO_SLOT",
    targetShape = lp.targets.PlusShape(5),

    targetActivate = function(ent, ppos)
        local slotEnt = lp.trySpawnSlot(ppos, server.entities.slot, ent.lootplotTeam)
        if slotEnt then
            slotEnt.doomCount = 4
        end
    end,
})

