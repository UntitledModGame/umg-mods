

local itemGenHelper = {}


---@param filterFunc fun(etype: EntityType): boolean
---@param weightAdjuster fun(etype: EntityType): number
---@return fun(): string entityType The entityType that was randomly selected
function itemGenHelper.createLazyGenerator(filterFunc, weightAdjuster)
    --[[
    Question: Why do we need this function?
        Why cant we just create a `newItemGenerator` directly...?

    Answer: Because `lp.newItemGenerator()` doesn't contain all the items at load-time.
        It only contains all the items at RUNTIME.
        Hence, we lazily-instantiate the generator object, 
        and pass the filter/weights at runtime.
        This ensures that we dont miss any items.
    ]]
    assert(filterFunc,"?")
    ---@type generation.Generator
    local itemGen
    local function generate()
        itemGen = itemGen or lp.newItemGenerator({
            filter = function(item, weight)
                local etype = assert(server.entities[item])
                local isUnlocked = lp.metaprogression.isEntityTypeUnlocked(etype)
                if isUnlocked then
                    return filterFunc(etype)
                end
                return false
            end,
            adjustWeights = function(item, currentWeight)
                local etype = server.entities[item]
                return weightAdjuster(etype)
            end
        })
        if itemGen:isEmpty() then
            return lp.FALLBACK_NULL_ITEM
        end
        return itemGen:query()
    end
    return generate
end




---@param etype EntityType
---@param rarities lootplot.rarities.Rarity[]
---@return boolean
function itemGenHelper.hasRarity(etype, rarities)
    for _, rar in ipairs(rarities) do
        if rar == etype.rarity then
            return true
        end
    end
    return false
end



--- Creates a rarity-weight adjuster, used to define weights for a random selection.
--- (Look at an example-usage if you are confused)
---@param weights {[string]: number}
---@return fun(etype: EntityType): number
function itemGenHelper.createRarityWeightAdjuster(weights)
    for rId,_ in pairs(weights) do
        assert(lp.rarities[rId], "Invalid rarity? " .. rId)
    end
    return function(etype)
        local r = etype.rarity
        ---@cast r lootplot.rarities.Rarity
        if r and weights[r.id] then
            return weights[r.id]
        end
        return 0
    end
end








return itemGenHelper
