local itemGenHelper = require("shared.item_gen_helper")

local loc = localization.localize

local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"LEVEL_UP"}
    end

    lp.defineItem("lootplot.s0:"..id, etype)
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

    sticky = true,

    shape = lp.targets.KingShape(1),
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
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}UNLOCK{/lootplot:TRIGGER_COLOR} for slots and items."),

    rarity = lp.rarities.RARE,

    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        activate = function(_, _, target)
            return lp.tryTriggerEntity("UNLOCK", target)
        end
    }
})




defItem("golden_bell", "Big Golden Bell", {
    basePrice = 6,

    activateDescription = loc("Converts slot into a {wavy}{lootplot:MONEY_COLOR}Golden Slot"),

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            lp.forceSpawnSlot(ppos, server.entities.golden_slot, ent.lootplotTeam)
        end
    end,

    baseMoneyGenerated = 5,
    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,
})



defItem("steel_bell", "Steel Bell", {
    basePrice = 6,

    activateDescription = loc("Spawns {lootplot:INFO_COLOR}Steel Slots{/lootplot:INFO_COLOR} that give {lootplot:BONUS_COLOR}+5 Bonus{/lootplot:BONUS_COLOR} and {lootplot:POINTS_MULT_COLOR}+1 Multiplier"),

    shape = lp.targets.RookShape(1),
    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            local slot = lp.forceSpawnSlot(ppos, server.entities.steel_slot, selfEnt.lootplotTeam)
            if slot then
                lp.modifierBuff(slot, "multGenerated", 1)
                lp.modifierBuff(slot, "bonusGenerated", 5)
            end
        end
    },

    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,
})



defItem("bronze_bell", "Bronze Bell", {
    basePrice = 8,

    activateDescription = loc("Gives slots {lootplot:POINTS_MULT_COLOR}+0.5 Multiplier{/lootplot:POINTS_MULT_COLOR}, but subtracts {lootplot:BONUS_COLOR}-2 Bonus"),

    shape = lp.targets.KingShape(2),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, slotEnt)
            lp.modifierBuff(slotEnt, "multGenerated", 1)
            lp.modifierBuff(slotEnt, "bonusGenerated", -5)
        end
    },

    sticky = true,

    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,
})




defItem("small_golden_bell", "Small Golden Bell", {
    --[[
    this item hopefully will show the player how LEVEL-UP system works.
    (Or at least, give them more intuition behind triggers and such)
    ]]
    basePrice = 4,

    sticky = true,

    baseMoneyGenerated = 5,
    baseMaxActivations = 4,

    rarity = lp.rarities.UNCOMMON,
})






local GOLD_COMPASS_AMOUNT = 12

defItem("gold_compass", "Gold Compass", {
    activateDescription = loc("Sets money to {lootplot:MONEY_COLOR}$%{amount}", {
        amount = GOLD_COMPASS_AMOUNT
    }),

    onActivate = function(ent)
        lp.setMoney(ent, GOLD_COMPASS_AMOUNT)
    end,

    basePrice = 8,
    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,
})




defItem("calender", "Calender", {
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} for all target-items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 10,
    baseMaxActivations = 4,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("LEVEL_UP", targetEnt)
        end
    }
})


