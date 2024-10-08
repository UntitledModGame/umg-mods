local loc = localization.localize



local function defineCard(name, cardEType)
    cardEType.rarity = cardEType.rarity or lp.rarities.RARE

    lp.defineItem(name, cardEType)
end


local function shuffle(tabl)
    -- fisher-yates shuffle table
    for i = #tabl, 2, -1 do
        local j = lp.SEED:randomMisc(1,i)
        tabl[i], tabl[j] = tabl[j], tabl[i]
    end
end


local function apply(tabl, shufFunc)
    for i=1, #tabl, 2 do
        local e1, e2 = tabl[i], tabl[i+1]
        shufFunc(e1, e2)
    end
end




defineCard("lootplot.content.s0:star_card", {
    image = "star_card",
    name = loc("Star Card"),

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.ABOVE_BELOW_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Shuffle shapes between target items"),
    },

    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        if not targets then
            return
        end

        local itemEntities = {}
        local itemEntShapes = {}

        for _, ppos in ipairs(targets) do
            local itemEnt = lp.posToItem(ppos)
            if itemEnt then
                itemEntities[#itemEntities+1] = itemEnt
                itemEntShapes[#itemEntities] = itemEnt.shape
            end
        end

        -- Shuffle shapes
        shuffle(itemEntShapes)

        -- Assign shapes
        for i, itemEnt in ipairs(itemEntities) do
            if itemEnt.shape ~= itemEntShapes[i] then
                lp.targets.setShape(itemEnt, itemEntShapes[i])
            end
        end
    end
})


defineCard("lootplot.content.s0:diamonds_card", {
    image = "diamonds_card",
    name = loc("Diamonds Card"),
    shape = lp.targets.ABOVE_BELOW_SHAPE,
    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Shuffle traits between target items"),
    },
    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        -- TODO
    end
})


defineCard("lootplot.content.s0:price_card", {
    image = "price_card",
    name = loc("Price Card"),

    shape = lp.targets.ABOVE_SHAPE,

    rarity = lp.rarities.EPIC,

    doomCount = 10,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Increase item price by 20%"),
        filter = function(targetEnt)
            return targetEnt.price
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local mod = targetEnt.price * 0.2
            lp.multiplierBuff(targetEnt, "price", mod, selfEnt)
        end
    }
})


defineCard("lootplot.content.s0:spades_card", {
    image = "spades_card",
    name = loc("Spades Card"),

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Shuffle positions of target items"),
    },

    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        if not targets then
            return
        end

        local slots = targets:map(lp.posToSlot)
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
})
