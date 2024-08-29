local loc = localization.localize

local function defineBook(id, name, description, targetSlot)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        minimumLevelToSpawn = 2,
        rarity = lp.rarities.UNCOMMON,

        targetType = "SLOT",
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivationDescription = loc(description),
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
    "Convert target slot into Normal Slot.",
    "slot"
)
defineBook("book_of_farming",
    "Book of Farming",
    "Convert target slot into Dirt Slot.",
    "dirt_slot"
)
defineBook("book_of_rerolling",
    "Book of Rerolling",
    "Convert target slot into Reroll Slot.",
    "reroll_slot"
)
defineBook("book_of_shopping",
    "Book of Shopping",
    "Convert target slot into Shop Slot.",
    "shop_slot"
)
defineBook("empty_book",
    "Empty book",
    "Convert target slot into Null Slot.",
    "null_slot"
)

