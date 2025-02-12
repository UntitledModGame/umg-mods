local loc = localization.localize



local bookTc = typecheck.assert("string", "string", "string|function", "string", "table")

local function defineBook(id, name, targetSlot, targetSlotName, rarity)
    bookTc(id, name, targetSlot, targetSlotName, rarity)
    return lp.defineItem("lootplot.s0:"..id, {
        image = id,
        name = loc(name),

        triggers = {"PULSE"},

        rarity = rarity,

        doomCount = 10,

        shape = lp.targets.UP_SHAPE,

        basePrice = 15,
        baseMaxActivations = 10,

        activateDescription = loc("Converts target slot(s) into " .. targetSlotName),

        target = {
            type = "SLOT",

            activate = function(selfEnt, ppos, targetEnt)
                local targSlot
                if type(targetSlot) == "function" then
                    targSlot = targetSlot(selfEnt)
                else
                    targSlot = targetSlot
                end

                local slotEType = server.entities["lootplot.s0:"..targSlot]
                if not slotEType then
                    return
                end
                lp.forceSpawnSlot(ppos, slotEType, selfEnt.lootplotTeam)
            end
        }
    })
end

-- FIXME: Ensure slots are defined, then remove the need to specify slot name.
defineBook("book_of_basics",
    "Book of Basics",
    "slot",
    "Normal Slot",
    lp.rarities.RARE
)
defineBook("book_of_rerolling",
    "Book of Rerolling",
    "reroll_slot",
    "Reroll Slot",
    lp.rarities.EPIC
)
defineBook("book_of_shopping",
    "Book of Shopping",
    "shop_slot",
    "Shop Slot",
    lp.rarities.EPIC
)
defineBook("book_of_selling",
    "Book of Selling",
    "sell_slot",
    "Sell Slot",
    lp.rarities.EPIC
)
defineBook("empty_book",
    "Empty book",
    "null_slot",
    "Null Slot",
    lp.rarities.RARE
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
    "{wavy amp=2}{lootplot:TRIGGER_COLOR}???{/lootplot:TRIGGER_COLOR}{/wavy}",
    lp.rarities.RARE
)

