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
            local targSlot
            if type(targetSlot) == "function" then
                targSlot = targetSlot(selfEnt)
            else
                targSlot = targetSlot
            end

            local newSlotEnt = server.entities["lootplot.content.s0:"..targSlot]
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
defineBook("book_of_selling",
    "Book of Selling",
    "sell_slot",
    "Sell Slot"
)
defineBook("empty_book",
    "Empty book",
    "null_slot",
    "Null Slot"
)


local mystery_slot_pool = {
    "null_slot", "reroll_slot",
    "dirt_slot", "glass_slot",
    "reroll_button_slot",
    "diamond_slot",
    "golden_slot"
}

defineBook("book_of_mystery",
    "Book of Mystery",
    function()
        --[[
        TODO: Use a proper query here please!!!
        ]]
        local rng = lp.SEED.miscRNG
        return table.random(mystery_slot_pool, rng)
    end,
    "{wavy amp=2}???"
)

