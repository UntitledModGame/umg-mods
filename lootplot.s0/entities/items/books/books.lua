
local loc = localization.localize

local helper = require("shared.helper")


local bookTc = typecheck.assert("string", "string", "string|function", "string", "table")





local function defineBook(id, name, etype)
    etype.image = id
    etype.name = loc(name)

    etype.triggers = {"PULSE"}

    etype.basePrice = 10
    etype.baseMaxActivations = 10

    etype.doomCount = 20
    etype.shape = lp.targets.UP_SHAPE

    lp.defineItem(  "lootplot.s0:" .. id, etype)
end

local function defineBasicBook(id, name, targetSlot, targetSlotName, rarity)
    bookTc(id, name, targetSlot, targetSlotName, rarity)
    local etype = {
        rarity = rarity,

        activateDescription = loc("Converts slot(s) into " .. targetSlotName),

        target = {
            type = "SLOT",

            filter = function(selfEnt, ppos, targetEnt)

                -- If there is only 1 buttonSlot of this type, 
                -- dont transform it.
                -- (We dont wanna softlock player)
                if targetEnt.buttonSlot then
                    local plot = ppos:getPlot()
                    local count = 0
                    plot:foreachSlot(function(slotEnt)
                        if slotEnt:type() == targetEnt:type() then
                            count = count + 1
                        end
                    end)
                    if count <= 1 then
                        return false
                    end
                end
                return true
            end,

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
    }

    return defineBook(id, name, etype)
end

-- FIXME: Ensure slots are defined, then remove the need to specify slot name.
defineBasicBook("book_of_basics",
    "Book of Basics",
    "slot",
    "Normal Slot",
    lp.rarities.RARE
)
defineBasicBook("book_of_rerolling",
    "Book of Rerolling",
    "reroll_slot",
    "Reroll Slot",
    lp.rarities.EPIC
)
defineBasicBook("book_of_shopping",
    "Book of Shopping",
    "shop_slot",
    "Shop Slot",
    lp.rarities.EPIC
)
defineBasicBook("book_of_selling",
    "Book of Selling",
    "sell_slot",
    "Sell Slot",
    lp.rarities.EPIC
)
defineBasicBook("empty_book",
    "Empty book",
    "null_slot",
    "Null Slot",
    lp.rarities.RARE
)


defineBook("book_of_mystery", "Book of Mystery", {
    rarity = lp.rarities.RARE,
    activateDescription = loc("Randomizes slots"),

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            helper.forceSpawnRandomSlot(ppos, selfEnt.lootplotTeam)
        end
    },
})

