

local loc = localization.localize


local function defineDice(id, name, etype)
    etype.name = loc(name)
    etype.rarity = assert(etype.rarity)

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




-- White Die: 
-- When rerolled, earn $2
defineDice("white_die", "White Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.EPIC,
    baseMoneyGenerated = 2
})



--[[

RED-DIE and GREEN-DIE synergize, 
by repeatedly acrivating each other.

]]
defineDice("red_die", "Red Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Triggers item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})

defineDice("green_die", "Green Die", {
    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Trigger REROLL for item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    }
})



--[[

TODO:
Black-die doesn't really fit here.

It should really be a food-item instead.

Maybe think of another purpose for it?
]]
defineDice("black_die", "Black Die", {
    rarity = lp.rarities.RARE,

    doomCount = 1,

    shape = lp.targets.LARGE_KING_SHAPE,

    target = {
        type = "NO_SLOT",
        description = loc("{lootplot.targets:COLOR}Spawns a DOOMED-4 Reroll slot."),
        activate = function(selfEnt, ppos)
            local slotEnt = lp.trySpawnSlot(ppos, server.entities.reroll_slot, selfEnt.lootplotTeam)
            slotEnt.doomCount = 4
        end
    }
})


