
local Query = require("shared.Query")


local Generator = objects.Class("generation:Generator")





function Generator:createQuery(rng)
    -- get the entries, and filter them:
    local query = Query({
        rng = rng or self.rng,
        generator = self
    })
    return query
end




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

local function assertPositiveNumber(x)
    if type(x) ~= "number" or x < 0 then
        umg.melt("Chance values must be positive numbers!")
    end
end




local defineEntryTc = typecheck.assert("table", "any", "table?")

function Generator:defineEntry(entry, options)
    defineEntryTc(self, entry, options)
    local entryObj = {
        defaultChance = options.defaultChance or 1,
        traits = options.traits or {},
        entry = entry
    }
    if entryObj.defaultChance then
        assertPositiveNumber(entryObj.defaultChance)
    end

    for trait, _ in pairs(entryObj.traits) do
        assert(type(trait) == "string", "Traits of entries must be strings!")
        local set = self.traitToEntries[trait] or objects.Set()
        self.traitToEntries[trait] = set
        set:add(entry)
    end

    self.allEntries:add(entry)
    self.nameToEntryObj[entry] = entryObj
end


local EMPTY_SET = objects.Set()

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
    return set
end



local tableTc = typecheck.assert("table")

function Generator:getEntriesWith(traits)
    tableTc(traits)
    if #traits == 1 then
        -- shortcircuit for efficiency
        return self.traitToEntries[traits[1]] or EMPTY_SET
    end

    local entrySet = findSmallestTraitSet(self, traits)
    for _, trait in ipairs(traits) do
        assert(type(trait) == "string", "Traits must be strings!")
        local traitSet = self.traitToEntries[trait] or EMPTY_SET
        entrySet = entrySet:intersection(traitSet)
    end
    return entrySet
end


function Generator:getAllEntries()
    return self.allEntries
end


local EMPTY = {}

local strTc = typecheck.assert("string")
function Generator:getTraits(entry)
    strTc(entry)
    local obj = self.nameToEntryObj[entry]
    if obj then
        return obj.traits or EMPTY
    end
    return EMPTY
end

function Generator:getDefaultChance(entry)
    strTc(entry)
    local obj = self.nameToEntryObj[entry]
    if obj then
        return obj.defaultChance or 1
    end
    return 1
end





return Generator

