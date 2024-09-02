local loc = localization.localize

local function defineBook(id, name, targetSlot, targetSlotName)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        minimumLevelToSpawn = 2,
        rarity = lp.rarities.UNCOMMON,

        targetType = "SLOT",
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivationDescription = loc("{lp_targetColor}Converts target slot into " .. targetSlotName),

        targetActivate = function(selfEnt, ppos, targetEnt)
            local newSlotEnt = server.entities["lootplot.content.s0:"..targetSlot]
            if newSlotEnt then
                lp.forceSpawnSlot(ppos, newSlotEnt, selfEnt.lootplotTeam)
            end
        end
    })
end

defineBook("book_of_basics",
    "Book of Basics",
    "slot",
    "Normal Slot"
)
defineBook("book_of_farming",
    "Book of Farming",
    "dirt_slot",
    "Dirt Slot"
)
defineBook("book_of_rerolling",
    "Book of Rerolling",
    "reroll_slot",
    "Reroll Slot"
)
defineBook("book_of_shopping",
    "Book of Shopping",
    "shop_slot",
    "Shop Slot"
)
defineBook("empty_book",
    "Empty book",
    "null_slot",
    "Null Slot"
)

