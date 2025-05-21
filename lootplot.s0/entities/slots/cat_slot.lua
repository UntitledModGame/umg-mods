
local itemGenHelper = require("shared.item_gen_helper")
local constants = require("shared.constants")


local loc = localization.localize


local function isCatItem(etype)
    return lp.hasTag(etype, constants.tags.CAT)
end

local WEIGHT = itemGenHelper.createRarityWeightAdjuster({
    UNCOMMON = 0.5,
    RARE = 1,
    EPIC = 0.333,
    LEGENDARY = 0.02,
})


local catGen = itemGenHelper.createLazyGenerator(function (etype)
    return isCatItem(etype)
end, WEIGHT)



return lp.defineSlot("lootplot.s0:cat_slot", {
    image = "cat_slot",
    name = loc("Cat slot"),

    baseMaxActivations = 1,

    triggers = {"PULSE"},
    activateDescription = loc("Spawns a random cat item"),

    rarity = lp.rarities.LEGENDARY,

    onActivate = function(slotEnt)
        local ppos = lp.getPos(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if (not ppos) or (itemEnt) then return end

        local itemType = catGen()
        local etype = itemType and server.entities[itemType]
        if etype then
            lp.forceSpawnItem(ppos, etype, slotEnt.lootplotTeam)
        end
    end
})



