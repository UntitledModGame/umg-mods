local Query = require("shared.Query")

---@class generation.Generator: objects.Class
local Generator = objects.Class("generation:Generator")

---@param rng love.RandomGenerator?
function Generator:init(rng)
    self.rng = rng or love.math.newRandomGenerator()

    self.traitToEntries = {--[[
        [tag] -> Set([entry1, entry2, ...])
    ]]}

    self.allEntries = objects.Set()

    self.nameToEntryObj = {--[[
        [entryName] -> entryObject
    ]]}
end

---@param rng love.RandomGenerator?
---@return generation.Query
function Generator:createQuery(rng)
    -- get the entries, and filter them:
    local query = Query({
        rng = rng or self.rng,
        generator = self
    })
    return query
end

local function assertPositiveNumber(x)
    if type(x) ~= "number" or x < 0 then
        umg.melt("Chance values must be positive numbers!")
    end
end




local defineEntryTc = typecheck.assert("table", "any", "table?")

---@class generation.EntryOptions
---@field public defaultChance? integer
---@field public traits table<string, any>?

---@param entry string
---@param options generation.EntryOptions?
function Generator:defineEntry(entry, options)
    defineEntryTc(self, entry, options)
    options = options or {}
    local entryObj = {
        defaultChance = options.defaultChance or 1,
        traits = table.deepCopy(options.traits) or {},
        entry = entry
    }
    assertPositiveNumber(entryObj.defaultChance)

    for trait in pairs(entryObj.traits) do
        assert(type(trait) == "string", "Traits of entries must be strings!")
        local set = self.traitToEntries[trait] or objects.Set()
        self.traitToEntries[trait] = set
        set:add(entry)
    end

    self.allEntries:add(entry)
    self.nameToEntryObj[entry] = entryObj
end


local EMPTY_SET = objects.Set()

---@param self generation.Generator
---@param traits string[]
local function findSmallestTraitSet(self, traits)
    --[[
        finds the trait that has the smallest number of entries,
        from a given list of traits.
    ]]
    local bestSize = math.huge
    local set = nil

    for _, t in ipairs(traits) do
        local traitSet = self.traitToEntries[t] or EMPTY_SET
        local size = #traitSet
        if size < bestSize then
            bestSize = size
            set = traitSet
        end
    end

    return set or EMPTY_SET
end

---@param ... string
---@return objects.Set
function Generator:getEntriesWith(...)
    if select("#", ...) == 1 then
        -- shortcircuit for efficiency
        return self.traitToEntries[select(1, ...)] or EMPTY_SET
    end

    local traits = {...}
    local entrySet = findSmallestTraitSet(self, traits)

    for _, trait in ipairs(traits) do
        assert(type(trait) == "string", "Traits must be strings!")
        local traitSet = self.traitToEntries[trait] or EMPTY_SET
        entrySet = entrySet:intersection(traitSet)
    end

    return entrySet
end

---@return objects.Set
function Generator:getAllEntries()
    return self.allEntries
end


local EMPTY = {}

local strTc = typecheck.assert("string")
---@param entry string
---@return table
function Generator:getTraits(entry)
    strTc(entry)
    local obj = self.nameToEntryObj[entry]
    local result = EMPTY

    if obj and obj.traits then
        result = table.shallowCopy(obj.traits)
    end

    return result
end

---@param entry string
---@return integer
function Generator:getDefaultChance(entry)
    strTc(entry)
    local obj = self.nameToEntryObj[entry]
    if obj then
        return obj.defaultChance or 1
    end
    return 1
end

---@cast Generator +fun(rng:love.RandomGenerator?):generation.Generator
return Generator
