local itemGenHelper = require("shared.item_gen_helper")

local loc = localization.localize

local SQUARE_BASKET_GEN = itemGenHelper.createLazyGenerator(
    function(etype)
        local rar = etype.rarity or lp.rarities.UNIQUE
        return lp.rarities.getWeight(rar) >= lp.rarities.getWeight(lp.rarities.UNCOMMON)
    end,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 2, UNCOMMON = 1
    })
)

lp.defineItem("lootplot.s0.content:square_basket", {
    name = loc("Square Basket"),
    rarity = lp.rarities.UNCOMMON,
    description = loc("Spawns %{COMMON} or %{UNCOMMON} items.", {
        COMMON = lp.rarities.COMMON.displayString,
        UNCOMMON = lp.rarities.UNCOMMON.displayString,
    }),
    triggers = {"LEVEL_UP"},

    doomCount = 1,
    shape = lp.targets.KING_SHAPE,
    target = {
        type = "SLOT_NO_ITEM",
        activate = function(self, ppos)
            local itemId = SQUARE_BASKET_GEN()
            if itemId then
                local itemEtype = server.entities[itemId]
                lp.trySpawnItem(ppos, itemEtype, self.lootplotTeam)
            end
        end,
    },
})
