local simplePicker = {}

---@generic T
---@param itemsAndWeights {[1]:T,[2]:number}[] List of items and its weights.
---@param rng love.RandomGenerator? Random number generator to use.
---@return T
function simplePicker.pickWeighted(itemsAndWeights, rng)
    local weightSum = 0

    for _, itemAndWeight in ipairs(itemsAndWeights) do
        assert(itemAndWeight[2] > 0, "weight must be positive larger than 0")
        weightSum = weightSum + itemAndWeight[2]
    end

    local number
    if rng then
        number = rng:random()
    else
        number = math.random()
    end
    number = number * weightSum

    for _, itemAndWeight in ipairs(itemsAndWeights) do
        number = number - itemAndWeight[2]
        if number <= 0 then
            return itemAndWeight[1]
        end
    end

    umg.melt("internal error")
    return nil
end


---@generic T
---@param items T[] List of items.
---@param weights number[] List of item weights.
---@param rng love.RandomGenerator? Random number generator to use.
---@return T
function simplePicker.pickWeightedPlanar(items, weights, rng)
    local weightSum = 0

    for _, weight in ipairs(weights) do
        assert(weight > 0, "weight must be positive larger than 0")
        weightSum = weightSum + weight
    end

    local number
    if rng then
        number = rng:random()
    else
        number = math.random()
    end
    number = number * weightSum

    for i, weight in ipairs(weights) do
        number = number - weight
        if number <= 0 then
            return items[i]
        end
    end

    umg.melt("internal error")
    return nil
end

return simplePicker
