local loc = localization.localize

---@param shape lootplot.targets.ShapeData
---@param action fun(selfEnt:lootplot.ItemEntity)
local function defineCard(id, name, description, shape, onetime, action)
    local t = {
        image = id,
        name = loc(name),
        targetType = "ITEM",
        targetActivationDescription = loc(description),
        targetShape = shape,
        onActivate = action
    }
    if onetime then
        t.doomCount = 1
    end
    return lp.defineItem("lootplot.content.s0:"..id, t)
end

defineCard("star_card",
    "Star Card",
    "Shuffle shapes of target items (ONE TIME USE)",
    lp.targets.ABOVE_BELOW_SHAPE,
    true,
    function(selfEnt)
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
)

defineCard("diamonds_card",
    "Diamonds Card",
    "Shuffle traits of target items (ONE TIME USE)",
    lp.targets.ABOVE_BELOW_SHAPE,
    true,
    function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        -- TODO
    end
)

defineCard("spades_card",
    "Spades Card",
    "Shuffle positions of target items",
    lp.targets.ABOVE_BELOW_SHAPE,
    false,
    function(selfEnt)
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
)