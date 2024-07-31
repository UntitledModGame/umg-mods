local loc = localization.localize

local function defineBook(id, name, description, targetSlot)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        targetType = "SLOT",
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivationDescription = loc(description),
        targetActivate = function(selfEnt, ppos, targetEnt)
            local newSlotEnt = server.entities["lootplot.content.s0"..targetSlot]()
            lp.setSlot(ppos, newSlotEnt)
        end
    })
end

defineBook("book_of_basics",
    "Book of Basics",
    "Convert target slots into normal slots",
    "slot"
)
defineBook("book_of_farming",
    "Book of Farming",
    "Convert target slots into dirt slots",
    "dirt_slot"
)
defineBook("book_of_rerolling",
    "Book of Rerolling",
    "Convert target slots into reroll slots",
    "reroll_slot"
)
defineBook("book_of_shopping",
    "Book of Shopping",
    "Convert target slots into shop slots",
    "shopSlot"
)
