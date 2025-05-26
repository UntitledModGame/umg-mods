
local itemGenHelper = require("shared.item_gen_helper")

local helper = require("shared.helper")
local constants = require("shared.constants")

local loc = localization.localize

local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.unlockAfterWins = constants.UNLOCK_AFTER_WINS.SKIP_LEVEL

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

    triggers = {"LEVEL_UP", "UNLOCK"},

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
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Unlock{/lootplot:TRIGGER_COLOR} for slots and items."),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(2),
    target = {
        type = "ITEM_OR_SLOT",
        filter = function(_, _, targEnt)
            return lp.hasTrigger(targEnt, "UNLOCK")
        end,
        activate = function(_, _, targEnt)
            return lp.tryTriggerEntity("UNLOCK", targEnt)
        end
    }
})




defItem("golden_bell", "Big Golden Bell", {
    basePrice = 8,

    activateDescription = loc("Gives {wavy}{lootplot:MONEY_COLOR}+$1 earned{/lootplot:MONEY_COLOR}{/wavy} to slot"),

    onActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt then
            lp.modifierBuff(slotEnt, "moneyGenerated", 1, ent)
        end
    end,

    baseMaxActivations = 2,

    sticky = true,

    rarity = lp.rarities.RARE,
})



defItem("steel_bell", "Steel Bell", {
    basePrice = 6,

    activateDescription = loc("Spawns {lootplot:INFO_COLOR}Steel Slots{/lootplot:INFO_COLOR} that give {lootplot:BONUS_COLOR}+5 Bonus{/lootplot:BONUS_COLOR}"),

    shape = lp.targets.RookShape(1),
    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            local slot = lp.forceSpawnSlot(ppos, server.entities.steel_slot, selfEnt.lootplotTeam)
            if slot then
                lp.modifierBuff(slot, "bonusGenerated", 5)
            end
        end
    },

    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,
})



defItem("bronze_bell", "Bronze Bell", {
    basePrice = 8,

    activateDescription = loc("Gives slots {lootplot:POINTS_MULT_COLOR}+1 Multiplier{/lootplot:POINTS_MULT_COLOR}, but subtracts {lootplot:BONUS_COLOR}-2 Bonus"),

    shape = lp.targets.KingShape(1),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, slotEnt)
            lp.modifierBuff(slotEnt, "multGenerated", 1)
            lp.modifierBuff(slotEnt, "bonusGenerated", -2)
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
    triggers = {"LEVEL_UP", "UNLOCK"},

    sticky = true,

    baseMoneyGenerated = 5,
    baseMaxActivations = 4,

    rarity = lp.rarities.UNCOMMON,
})






defItem("golden_compass", "Golden Compass", {
    activateDescription = loc("Make {lootplot:INFO_COLOR}glass-slots{/lootplot:INFO_COLOR} earn {lootplot:MONEY_COLOR}$1."),

    shape = lp.targets.UpShape(1),
    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targEnt)
            return lp.hasTag(targEnt, constants.tags.GLASS_SLOT)
        end,
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "moneyGenerated", 1, selfEnt)
        end
    },

    basePrice = 12,
    baseMaxActivations = 4,

    rarity = lp.rarities.EPIC,
})




defItem("calendar", "Calendar", {
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} on items."),

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


