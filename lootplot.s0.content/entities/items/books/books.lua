local loc = localization.localize



local bookTc = typecheck.assert("string", "string", "string|function", "string", "table")

local function defineBook(id, name, targetSlot, targetSlotName, rarity)
    bookTc(id, name, targetSlot, targetSlotName, rarity)
    return lp.defineItem("lootplot.s0.content:"..id, {
        image = id,
        name = loc(name),

        triggers = {"PULSE"},

        rarity = rarity,

        doomCount = 10,

        shape = lp.targets.UP_SHAPE,

        basePrice = 15,
        baseMaxActivations = 1,

        target = {
            type = "SLOT",
            description = loc("Converts target slot into " .. targetSlotName),

            activate = function(selfEnt, ppos, targetEnt)
                local targSlot
                if type(targetSlot) == "function" then
                    targSlot = targetSlot(selfEnt)
                else
                    targSlot = targetSlot
                end

                local slotEType = server.entities["lootplot.s0.content:"..targSlot]
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
    "weak_shop_slot",
    "Weak Shop Slot",
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




local buffBookTc = typecheck.assert("string", "string", "function")

local function defineBuffingBook(id, name, targetDescription, func)
    buffBookTc(id, name, func)

    return lp.defineItem("lootplot.s0.content:"..id, {
        image = id,
        name = loc(name),

        rarity = lp.rarities.RARE,

        doomCount = 4,

        shape = lp.targets.UP_SHAPE,
        triggers = {"PULSE"},

        basePrice = 15,
        baseMaxActivations = 100,

        target = {
            type = "SLOT",
            description = loc(targetDescription),
            activate = function(selfEnt, ppos, targetEnt)
                func(targetEnt, selfEnt)
            end
        }
    })
end


defineBuffingBook("points_book", "Points Book", "Adds {lootplot:POINTS_MOD_COLOR}+100{/lootplot:POINTS_MOD_COLOR} points to target slot permanently!", function(slotEnt, bookEnt)
    lp.modifierBuff(slotEnt, "pointsGenerated", 100)
end)

defineBuffingBook("multiplication_book", "Multiplication Book", "Gives a {lootplot:POINTS_MULT_COLOR}x2 points multiplier{/lootplot:POINTS_MULT_COLOR} to target slot permanently!\n{lootplot:INFO_COLOR}(Maximum of 100)", function(slotEnt, bookEnt)
    local _, _, mult = properties.computeProperty(slotEnt, "pointsGenerated")
    if mult < 100 then
        lp.multiplierBuff(slotEnt, "pointsGenerated", 2)
    end
end)


