local itemGenHelper = require("shared.item_gen_helper")

local loc = localization.localize

local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"LEVEL_UP"}
    end

    lp.defineItem("lootplot.s0.content:"..id, etype)
end



local SQUARE_BASKET_GEN = itemGenHelper.createLazyGenerator(
    function() return true end,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 2, UNCOMMON = 1
    })
)

defItem("square_basket", "Square Basket", {
    activateDescription = loc("Spawns %{COMMON} or %{UNCOMMON} items.", {
        COMMON = lp.rarities.COMMON.displayString,
        UNCOMMON = lp.rarities.UNCOMMON.displayString,
    }),
    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),
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



defItem("red_key", "Red Key", {
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}UNLOCK{lootplot:TRIGGER_COLOR} for slots and items."),

    rarity = lp.rarities.RARE,

    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        activate = function(_, _, target)
            return lp.tryTriggerEntity("UNLOCK", target)
        end
    }
})




defItem("gold_bell", "Gold Bell", {
    basePrice = 6,

    baseMoneyGenerated = 6,
    baseMaxActivations = 1,

    rarity = lp.rarities.RARE,
})




defItem("calender", "Calender", {
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} for all target-items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 10,
    baseMaxActivations = 1,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("LEVEL_UP", targetEnt)
        end
    }
})


