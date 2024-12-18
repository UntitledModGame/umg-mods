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
    description = loc("Spawns %{COMMON} or %{UNCOMMON} items.", {
        COMMON = lp.rarities.COMMON.displayString,
        UNCOMMON = lp.rarities.UNCOMMON.displayString,
    }),
    rarity = lp.rarities.UNCOMMON,
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



lp.defineItem("lootplot.s0.content:red_key", {
    name = loc("Red Key"),
    image = "red_key",
    description = loc("Trigger %{UNLOCK} to items and slots.", {UNLOCK = lp.getTriggerDisplayName("UNLOCK")}),
    rarity = lp.rarities.RARE,
    triggers = {"LEVEL_UP"},

    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        activate = function(self, ppos)
            local target = lp.posToItem(ppos) or lp.posToSlot(ppos)
            if target then
                lp.tryTriggerEntity("UNLOCK", target)
            end
        end
    }
})




lp.defineItem("lootplot.s0.content:gold_bell", {
    name = loc("Golden Bell"),
    image = "gold_bell",
    basePrice = 6,

    baseMoneyGenerated = 10,
    baseMaxActivations = 1,

    rarity = lp.rarities.UNCOMMON,
    triggers = {"LEVEL_UP"},
})
