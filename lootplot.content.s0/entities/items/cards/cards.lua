local loc = localization.localize

lp.defineItem("lootplot.content.s0:star_card", {
    image = "star_card",
    name = loc("Star Card"),
    targetType = "ITEM",
    targetActivationDescription = loc("Shuffle shapes of target items."),
    targetShape = lp.targets.ABOVE_BELOW_SHAPE,
    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)

        if targets then
            local itemEntities = {}
            local itemEntShapes = {}

            for _, ppos in ipairs(targets) do
                local itemEnt = lp.posToItem(ppos)
                if itemEnt then
                    itemEntities[#itemEntities+1] = itemEnt
                    itemEntShapes[#itemEntities] = itemEnt.targetShape
                end
            end

            -- Shuffle shapes
            for i = #itemEntShapes, 2, -1 do
                local j = math.random(1, i)
                itemEntShapes[i], itemEntShapes[j] = itemEntShapes[j], itemEntShapes[i]
            end

            -- Assign shapes
            for i, itemEnt in ipairs(itemEntities) do
                if itemEnt.targetShape ~= itemEntShapes[i] then
                    lp.targets.setTargetShape(itemEnt, itemEntShapes[i])
                end
            end
        end
    end
})

lp.defineItem("lootplot.content.s0:diamonds_card", {
    image = "diamonds_card",
    name = loc("Diamonds Card"),
    targetType = "ITEM",
    targetActivationDescription = loc("Shuffle traits of target items."),
    targetShape = lp.targets.ABOVE_BELOW_SHAPE,
    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        -- TODO
    end
})

lp.defineItem("lootplot.content.s0:spades_card", {
    image = "spades_card",
    name = loc("Spades Card"),
    targetType = "ITEM",
    targetActivationDescription = loc("Shuffle positions of target items"),
    targetShape = lp.targets.ABOVE_BELOW_SHAPE,
    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)

        if targets then
            local slots = targets:map(lp.itemToSlot)

            -- Shuffle it
            for i = #slots, 2, -1 do
                local j = math.random(1, i)
                slots[i], slots[j] = slots[j], slots[i]
            end

            -- Swap item positions
            for i = 1, #slots - 1 do
                local s1 = slots[i]
                local s2 = slots[i + 1]
                if lp.canSwap(s1, s2) then
                    lp.swapItems(s1, s2)
                end
            end
        end
    end
})
