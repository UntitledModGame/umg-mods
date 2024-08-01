local loc = localization.localize

local rareItemReroller = lp.ITEM_GENERATOR
    :createQuery()
    :addAllEntries()
    :filter(function(entry, traits, chance)
        local etype = server.entities[entry]
        return etype and etype.rarity and lp.rarities.compare(etype.rarity, lp.rarities.RARE) >= 0
    end
)

lp.defineItem("lootplot.content.s0:gift_box", {
    image = "gift_box",
    name = loc("Gift Box"),
    description = loc("After 3 activations, transform into a RARE item."),
    onActivate = function(selfEnt)
        if selfEnt.totalActivationCount >= 3 then
            local ppos = lp.getPos(selfEnt)
            if ppos then
                local etype = server.entities[rareItemReroller()]

                if etype then
                    lp.forceSpawnItem(ppos, etype)
                end
            end
        end
    end
})

lp.defineItem("lootplot.content.s0:money_box", {
    image = "money_box",
    name = loc("Dollar Box"),
    description = loc("Transform into a RARE item that costs $1 to use"),
    baseMoneyGenerated = -1,
    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos then
            local etype = server.entities[rareItemReroller()]

            if etype then
                lp.forceSpawnItem(ppos, etype)
            end
        end
    end
})

lp.defineItem("lootplot.content.s0:pandoras_box", {
    image = "pandoras_box",
    name = loc("Pandora's Box"),

    targetType = "SLOT",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Spawn a RARE item in an ABOVE shape that has only 1 use."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local etype = server.entities[rareItemReroller()]

        if etype then
            lp.trySpawnItem(ppos, etype)
        end
    end
})


lp.defineItem("lootplot.content.s0:boomerang", {
    image = "boomerang",
    name = loc("Boomerang"),
    description = loc("+1 points. Uses all activations at once."),
    -- TODO: Oli, please implement this OK!
})


lp.defineItem("lootplot.content.s0:red_shield", {
    image = "red_shield",
    name = loc("Red Shield"),

    targetType = "ITEM",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = loc("Triggers PULSE for all target items."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.tryTriggerEntity("PULSE", targetEnt)
    end
})

lp.defineItem("lootplot.content.s0:green_shield", {
    image = "green_shield",
    name = loc("Green Shield"),

    targetType = "ITEM",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = loc("Triggers REROLL for all target items."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.tryTriggerEntity("REROLL", targetEnt)
    end
})
