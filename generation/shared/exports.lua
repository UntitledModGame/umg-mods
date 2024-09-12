---@meta

---Availability: Client and Server
local generation = {}
if false then _G.generation = generation end

---Availability: Client and Server
generation.Generator = require("shared.Generator")
---Availability: Client and Server
generation.Picker = require("shared.Picker")

---Availability: Client and Server
---@deprecated use generation.Generator instead.
generation.LegacyGenerator = require("shared.LegacyGenerator")

local simplePicker = require("shared.simple_picker")

---Randomly picks an item from the list.
---
---If you don't need weighted pick, consider using `table.pick_random` instead.
---
---Availability: Client and Server
---@generic T
---@param itemsAndWeights {[1]:T,[2]:number}[] List of items and its weights.
---@param rng love.RandomGenerator? Random number generator to use.
---@return T
function generation.pickWeighted(itemsAndWeights, rng)
    return simplePicker.pickWeighted(itemsAndWeights, rng)
end

---Randomly picks an item from the list.
---
---If all weights are in equal size pick, consider using `table.pick_random` instead.
---
---Availability: Client and Server
---@generic T
---@param items T[] List of items.
---@param weights number[] List of item weights.
---@param rng love.RandomGenerator? Random number generator to use.
---@return T
function generation.pickWeightedPlanar(items, weights, rng)
    return simplePicker.pickWeightedPlanar(items, weights, rng)
end

umg.expose("generation", generation)
return generation
