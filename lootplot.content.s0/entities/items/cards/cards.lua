local loc = localization.localize

---@param action fun(selfEnt:lootplot.ItemEntity)
local function defineCard(id, name, description, shape, onetime, action)
    local t = {
        image = id,
        name = loc(name),
        description = loc(description),
        targetType = "ITEM",
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
            -- Shuffle it
            for i = #targets, 2, -1 do
                local j = math.random(1, i)
                targets[i], targets[j] = targets[j], targets[i]
            end

            for i = 1, #targets - 1 do
                local e1 = targets[i]
                local e2 = targets[i + 1]
                -- Does this work?
                e1.targetShape, e2.targetShape = e2.targetShape, e1.targetShape
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
