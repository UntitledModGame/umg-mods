

local loc = localization.localize


local function defineFood(entName, etype)
    etype.doomCount = etype.doomCount or 1

    lp.defineItem(entName, etype)
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
        local etype = server.entities["lootplot.content.s0:golden_slot"]
        assert(etype,"?")
        lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
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
        assert(etype,"?")
        lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
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
        if slotEnt then
            local clone = slotEnt:clone()
            lp.setSlot(ppos, clone)
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

    targetActivationDescription = loc("{lp_targetColor}Spawns glass slots"),

    targetActivate = function(selfEnt, ppos)
        local etype = server.entities["lootplot.content.s0:glass_slot"]
        if etype then
            lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    end
})

defineFood("lootplot.content.s0:glass_tube", {
    image = "glass_tube",

    name = loc("Glass tube"),
    targetActivationDescription = loc("{lp_targetColor}Spawns glass slots"),

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

    name = loc("pomegranate"),
    targetActivationDescription = loc("{lp_targetColor}Spawns normal slots"),

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

    name = loc("dragonfruit"),
    targetActivationDescription = loc("{lp_targetColor}Spawns normal slots"),

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

    name = loc("soy sauce"),
    targetActivationDescription = loc("{lp_targetColor}Spawns doomed-4 slots"),

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


defineFood("lootplot.content.s0:dirty_muffin", {
    image = "dirty_muffin",

    name = loc("Dirty Muffin"),
    targetActivationDescription = loc("{lp_targetColor}Convert slots into dirt"),

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 4,

    baseBuyPrice = 2,
    baseTraits = {},

    targetType = "SLOT",
    targetShape = lp.targets.LARGE_KING_SHAPE,

    targetActivate = function(ent, ppos)
        lp.forceSpawnSlot(ppos, server.entities.dirt_slot, ent.lootplotTeam)
    end,
})


defineFood("lootplot.content.s0:coconut", {
    image = "coconut",

    name = loc("Coconut"),
    targetActivationDescription = loc("{lp_targetColor}Spawns dirt slots"),

    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 4,

    baseBuyPrice = 4,
    baseTraits = {},

    targetType = "NO_SLOT",
    targetShape = lp.targets.PlusShape(2),

    targetActivate = function(ent, ppos)
        lp.trySpawnSlot(ppos, server.entities.dirt_slot, ent.lootplotTeam)
    end,
})

