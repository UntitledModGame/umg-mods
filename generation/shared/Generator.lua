---@class (exact) generation.Generator: objects.Class
---@field protected rng love.RandomGenerator
---@field protected entries any[]
---@field protected weights number[]
---@field protected cumulativeWeights number[]
---@field protected traits (table<string,any>?)[]
---@field protected addedEntries objects.Set
local Generator = objects.Class("generation:Generator")

---Cannot use table.shallowCopy as it stops on first nil.
---@generic T
---@param src T[]
---@param dest T[]
---@param count integer
local function copyByAmount(src, dest, count)
    for i = 1, count do
        dest[i] = src[i]
    end
end

---@generic T
---@param t T[]
---@param amount integer
---@param start integer?
---@param tablength integer?
local function shift(t, amount, start, tablength)
    start = start or 1
    tablength = tablength or #t

    for i = start, tablength do
        t[i] = t[i + amount]
    end

    t[tablength - amount + 1] = nil
end

---@param rng love.RandomGenerator?
function Generator:init(rng)
    self.rng = rng or love.math.newRandomGenerator(love.math.random(0, 2147483647))
    self.entries = {}
    self.weights = {}
    self.cumulativeWeights = {} -- for fast lookup
    self.traits = {}
    self.addedEntries = objects.Set()
end

if false then
    ---Create a new Generator object.
    ---@param rng love.RandomGenerator? Random number generator to use, or `nil` to create new one.
    ---@return generation.Generator
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function Generator(rng) end
end

---Duplicate the current generator. The duplicated generator has independent state with the original generator.
---Any mutable operators done by the duplicated generator won't affect the original generator.
---@param rng love.RandomGenerator? Random number generator to use, or `nil` to create new one.
function Generator:clone(rng)
    local gen = Generator(rng)
    copyByAmount(self.entries, gen.entries, #self.entries)
    copyByAmount(self.weights, gen.weights, #self.entries)
    copyByAmount(self.cumulativeWeights, gen.cumulativeWeights, #self.entries)
    copyByAmount(self.traits, gen.traits, #self.entries)
    gen.addedEntries = objects.Set(self.addedEntries)
    return gen
end

---Clones and filter the items in the pool so that entires that didn't pass the filter function won't be in the newly
---created generator.
---
---This is more efficient alternative to `Generator:clone()` followed by `Generator:filter()`.
---@param rng love.RandomGenerator? Random number generator to use, or `nil` to create new one.
---@param filterFunction fun(entry:any,traits:table<string,any>?):boolean Filter funtion that returns `true` to allow the item in the new generator, `false` otherwise.
function Generator:cloneWithFilter(rng, filterFunction)
    local gen = Generator(rng)
    local tempOptions = {weight = 1, traits = nil}

    for i, entry in ipairs(self.entries) do
        if filterFunction(entry, self.traits[i]) then
            tempOptions.weight = self.weights[i]
            tempOptions.traits = self.traits[i]
            gen:add(entry, tempOptions)
        end
    end

    return gen
end

function Generator:getEntryCount()
    return #self.entries
end

---@class generator.GeneratorEntryOptions: {[any]:any}
---@field public weight number?
---@field public traits table<string,any>?

---Add new entry to the generator. Note that you **can't** add multiple entries.
---
---**This mutates the `Generator`.**
---@param entry any Entry to add (any type except `nil` is allowed)
---@param options generator.GeneratorEntryOptions? Additional options to specify.
function Generator:add(entry, options)
    assert(entry ~= nil, "entry must be non-nil value")
    assert(not self.addedEntries:has(entry), "attempt to add duplicate entry")

    local weight = 1
    local traits = nil

    if options then
        weight = options.weight or weight
        traits = options.traits
    end

    local next = #self.entries + 1
    self.entries[next] = entry
    self.weights[next] = weight
    self.cumulativeWeights[next] = (self.cumulativeWeights[next - 1] or 0) + weight
    self.traits[next] = traits
end

---Removes an item from the entry.
---
---**This mutates the `Generator`.**
---@param entry any Entry to remove.
---@return generation.EntryOptions?
function Generator:remove(entry)
    assert(entry ~= nil, "entry must be non-nil value")

    for i, existingEntry in ipairs(self.entries) do
        if existingEntry == entry then
            local opts = {weights = self.weights[i], traits = self.traits[i]}
            shift(self.entries, 1, i, #self.entries)
            shift(self.weights, 1, i, #self.entries)
            shift(self.cumulativeWeights, 1, i, #self.entries)
            shift(self.traits, 1, i, #self.entries)
            self.addedEntries:remove(entry)
            self:_updateCumulativeWeights(i)
            return opts
        end
    end

    return nil
end

---@param start integer?
---@protected
function Generator:_updateCumulativeWeights(start)
    start = start or 1
    local sum = self.cumulativeWeights[start - 1] or 0

    for i = start, #self.entries do
        sum = sum + self.weights[i]
        self.cumulativeWeights[i] = sum
    end

    self.cumulativeWeights[#self.entries + 1] = nil
end

---Filters items in the pool so that entires that didn't pass the filter function will be removed.
---
---**This mutates the `Generator`.**
---@param filterFunction fun(entry:any,traits:table<string,any>?):boolean Filter funtion that returns `true` to keep the item, `false` to remove.
function Generator:filter(filterFunction)
    local newEntries = {}
    local newWeights = {}
    local newTraits = {}

    for i, entry in ipairs(self.entries) do
        if filterFunction(entry, self.traits[i]) then
            local next = #newEntries + 1
            newEntries[next] = entry
            newWeights[next] = self.weights[i]
            newTraits[next] = self.traits[i]
        end
    end

    self.entries = newEntries
    self.weights = newWeights
    table.clear(self.cumulativeWeights)
    self.traits = newTraits
    return self:_updateCumulativeWeights()
end

---Updates the weight of items in the pool.
---
---**This mutates the `Generator`.**
---@param transformWeightFunction fun(item:any,currentWeight:number,traits:table<string,any>?):number Function that returns new weight of specified item.
function Generator:updateWeights(transformWeightFunction)
    for i, entry in ipairs(self.entries) do
        self.weights[i] = transformWeightFunction(entry, self.weights[i], self.traits[i])
    end

    self:_updateCumulativeWeights()
end

local function dummyTrue()
    return true
end

function Generator:_findIndexByCWeight(cweight)
    -- Perform binary search
    local start = 1
    local stop = #self.entries

    while start <= stop do
        local mid = math.floor((start + stop) / 2)

        if cweight >= (self.cumulativeWeights[mid - 1] or 0) then
            if cweight <= self.cumulativeWeights[mid] then
                return mid
            else
                start = mid + 1
            end
        else
            stop = mid - 1
        end
    end

    return nil
end

---Get random entry from the generator. This keep the entry in the generator.
---@param filterFunction (fun(entry:any,traits:table<string,any>?):boolean)? Filter funtion that returns `true` to consider the item, `false` to reroll.
---@return any
function Generator:query(filterFunction)
    filterFunction = filterFunction or dummyTrue
    assert(#self.entries > 0, "no items in entry")

    local filtered = {}
    local filteredCount = 0

    while filteredCount < #self.entries do
        local dice = self.rng:random() * self.cumulativeWeights[#self.entries]
        local index = assert(self:_findIndexByCWeight(dice), "internal error")
        local entry = self.entries[index]

        if filterFunction(entry, self.traits[index]) then
            return entry
        else
            if not filtered[index] then
                filteredCount = filteredCount + 1
                filtered[index] = true
            end
        end
    end
end

return Generator
