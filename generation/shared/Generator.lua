
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




function Generator:init()
    self.rng = love.math.newRandomGenerator()

    self.traitToEntries = {--[[
        [tag] -> Set([entryObj, entryObj, ...])
    ]]}

    self.allEntries = objects.Set()

    self.nameToEntryObj = {--[[
        [entryName] -> entryObject
    ]]}
end




function Generator:defineEntry(entry, options)
    local entryObj = {
        defaultChance = options.defaultChance or 1,
        traits = options.traits or {},
        entry = entry
    }

    for _, trait in pairs(entryObj.traits) do
        local set = self.traitToEntries[trait] or objects.Set()
        self.traitToEntries[trait] = set
        set:add(entry)
    end

    self.allEntries:add(entry)
    self.nameToEntryObj[entry] = entryObj
end



local function findSmallestTraitSet(self, traits)
    --[[
        finds the trait that has the smallest number of entries,
        from a given list of traits.
    ]]
    local bestSize = math.huge
    local set = nil

    for _, t in ipairs(traits) do
        local traitSet = self.traitToEntries[t]
        local size = #traitSet
        if size < bestSize then
            bestSize = size
            set = traitSet
        end
    end
    return set
end


function Generator:getEntriesWith(traits)
    if #traits == 1 then
        -- shortcircuit for efficiency
        return self.traitToEntries[traits[1]]
    end

    local entrySet = findSmallestTraitSet(self, traits)
    for _, trait in ipairs(traits) do
        local traitSet = self.traitToEntries[trait]
        entrySet = entrySet:intersection(traitSet)
    end
    return entrySet
end


function Generator:getAllEntries()
    return self.allEntries
end


local EMPTY = {}
function Generator:getTraits(entry)
    return self.nameToEntryObj[entry].traits or EMPTY
end

function Generator:getDefaultChance(entry)
    return self.nameToEntryObj[entry].defaultChance or 1
end





return Generator

