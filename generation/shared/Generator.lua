local Picker = require("shared.Picker")

---@class generation.Generator: objects.Class
---@field protected rng love.RandomGenerator
---@field protected entries any[]
---@field protected weights number[]
---@field protected picker generation.Picker?
local Generator = objects.Class("generation:Generator")


---@param rng love.RandomGenerator?
function Generator:init(rng)
    self.rng = rng or love.math.newRandomGenerator(love.math.random(0, 2147483647))
    assert(typecheck.isType(self.rng, "love:RandomGenerator"))
    self.entries = {}
    self.weights = {}
    self.picker = nil
end

if false then
    ---Create a new Generator object.
    ---@param rng love.RandomGenerator? Random number generator to use, or `nil` to create new one.
    ---@return generation.Generator
    function Generator(rng) end ---@diagnostic disable-line: missing-return, cast-local-type
end

---Duplicate the current generator. The duplicated generator has independent state with the original generator.
---Any mutable operators done by the duplicated generator won't affect the original generator.
---@param rng love.RandomGenerator? Random number generator to use, or `nil` to share with current random number generator.
---@return generation.Generator
function Generator:clone(rng)
    return self:cloneWith(rng or self.rng)
end

local function dummyTrue()
    return true
end

local function keepWeights(_, currentWeight)
    return currentWeight
end

---@alias generation.CloneOptions {filter?:(fun(item:any,weight:number):boolean),adjustWeights?:(fun(item:any,currentWeight:number):number)}? Additional table options: `filter` to specify clone filtering, `adjustWeights` to adjust the weights of items in cloned generator.

---Clones the generator while at same time filter out items and re-adjust the item weights if necessary.
---
---This is more efficient alternative to `Generator:clone()` followed by `Generator:filter()` and/or `Generator:adjustWeights()`.
---@param rng love.RandomGenerator Random number generator to use.
---@param options generation.CloneOptions
---@return generation.Generator
function Generator:cloneWith(rng, options)
    local gen = Generator(rng)
    local filter = dummyTrue
    local adjustWeights = keepWeights

    if options then
        filter = options.filter or filter
        adjustWeights = options.adjustWeights or adjustWeights
    end

    for i, entry in ipairs(self.entries) do
        local weight = self.weights[i]
        if filter(entry, weight) then
            weight = adjustWeights(entry, weight)

            if weight > 0 then
                gen:add(entry, weight)
            end
        end
    end

    return gen
end


--- WARNING: Do not mutate!!!!
---@return any[]
function Generator:getEntries()
    -- HMM: should we shallow clone?
    return self.entries
end



---@return boolean
function Generator:isEmpty()
    return (#self.entries) <= 0
end



---Add new entry to the generator.
---
---**This mutates the `Generator`.**
---@param entry any Entry to add (any type except `nil` is allowed)
---@param weight number? The entry weight (default to 1)
---@return generation.Generator
function Generator:add(entry, weight)
    assert(entry ~= nil, "entry must be non-nil value")

    local next = #self.entries + 1
    self.entries[next] = entry
    self.weights[next] = weight
    return self
end

---Removes first occurence of item from the entry.
---
---**This mutates the `Generator`.**
---@param entry any Entry to remove.
---@return number? @The removed entry weight, or `nil` if not found.
function Generator:remove(entry)
    assert(entry ~= nil, "entry must be non-nil value")

    for i, existingEntry in ipairs(self.entries) do
        if existingEntry == entry then
            table.remove(self.entries, i)
            return table.remove(self.weights, i)
        end
    end

    return nil
end

---Filters items in the pool so that entires that didn't pass the filter function will be removed.
---@param filterFunction fun(entry:any,weight:number):boolean Filter funtion that returns `true` to keep the item, `false` to remove.
function Generator:filter(filterFunction)
    return self:cloneWith(self.rng, {filter = filterFunction})
end

---Creates new generator that contains same set of items but with modified weights according to a function.
---@param transformWeightFunction fun(item:any,currentWeight:number):number Function that returns new weight of specified item.
function Generator:adjustWeights(transformWeightFunction)
    return self:cloneWith(self.rng, {adjustWeights = transformWeightFunction})
end


local function ensurePickerExists(self)
    if self.picker then
        return
    end

    local itemIndices = {}
    for i = 1, #self.entries do
        itemIndices[i] = i
    end
    self.picker = Picker(itemIndices, self.weights)
end




-- todo: should we make this number configurable??
local NUM_TRIES = 500

local function alwaysPick()
    return 1
end

---@alias generation.PickChanceFunction (fun(entry:any,weight:table<string,any>?):number)

---Get random entry from the generator.
---@param rgen love.RandomGenerator?
---@param pickChanceFunction generation.PickChanceFunction? Function that returns the chance of an item being picked. 1 means pick always, 0 means fully skip this item (filtered out), anything inbetween is the chance of said entry be accepted or be rerolled.
---@return any?
function Generator:query(rgen, pickChanceFunction)
    rgen = rgen or self.rng
    if type(rgen.random) ~= "function" then
        print(rgen, type(rgen), rgen.random)
    end
    pickChanceFunction = pickChanceFunction or alwaysPick

    assert(#self.entries > 0, "no items in entry")

    ensurePickerExists(self)

    local i = 0
    local weightCache = {}

    while i < NUM_TRIES do
        local index = self.picker:pick(rgen)

        local entry = self.entries[index]
        local chance = weightCache[index] or math.clamp(pickChanceFunction(entry, self.weights[index]), 0, 1)
        weightCache[index] = chance
        if rgen:random() < chance then
            return entry
        end
        i = i + 1
    end

    umg.log.error(debug.traceback("LOOKUP FAILED!"))
    return nil -- Query failed; looped for too long
end

return Generator
