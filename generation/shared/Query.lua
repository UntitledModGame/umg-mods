
local Picker = require("shared.Picker")


local Query = objects.Class("generation:Query")


local ARGS = {"rng", "generator"}
function Query:init(args)
    typecheck.assertKeys(args, ARGS)

    -- you won't need to modify ANY of these fields outside this module.
    self.rng = args.rng
    self.generator = args.generator

    self.seenPicks = {--[[
        [entry] -> {chance=X, entry=X}
    ]]}
    self.picks = objects.Array(--[[
        {chance=X, entry=X}
    ]])

    self.filters = objects.Array()
    self.chanceAdjusters = objects.Array()

    self.outdated = true
    self.picker = nil

    self.nestedQueries = objects.Set()
end



local finalize

function Query:__call()
    -- executing a query:
    if self.outdated then
        finalize(self)
    end

    local r1 = self.rng:random()
    local r2 = self.rng:random()
    local result = self.picker:pick(r1,r2)
    if Query:isInstance(result) then
        -- its a nested query: call again
        return result()
    end
    return result -- else, its an entry.
end


function Query:isEmpty()
    return #self.picks <= 0
end


local function newPick(entry, chance)
    return {
        entry = entry,
        chance = chance
    }
end


local function assertPositiveNumber(x)
    if type(x) ~= "number" or x < 0 then
        umg.melt("Chance values must be positive numbers!", 3)
    end
end


local function markOutdated(self)
    self.outdated = true
end


local addTc = typecheck.assert("table", "any", "number")

function Query:add(entry_or_query, chance)
    --[[
        TODO:
        Should we be checking for loops here?
        ie. query references itself...
        We dont want querys querying themselves.... thatd be bad
    ]]
    addTc(self, entry_or_query, chance)

    if self.seenPicks[entry_or_query] then
        -- The pick already exists; So, overwrite the chance:
        local pick = self.seenPicks[entry_or_query]
        pick.chance = chance
    else
        local pick = newPick(entry_or_query, chance)
        self.picks:add(pick)
        self.seenPicks[entry_or_query] = pick
    end

    markOutdated(self)
    return self
end


function Query:filter(f)
    self.filters:add(f)
    markOutdated(self)
    return self
end

function Query:adjustChances(f)
    self.chanceAdjusters:add(f)
    markOutdated(self)
    return self
end




local function getTraits(self, entry)
    return self.generator:getTraits(entry)
end

local function addDefault(self, entry)
    local chance = self.generator:getDefaultChance(entry)
    self:add(entry, chance)
end


function Query:addEntriesWith(...)
    --[[
        adds entries with ALL of the traits listed.
    ]]
    local traits = {...}
    local entries = self.generator:getEntriesWith(traits)
    for _, entry in ipairs(entries) do
        addDefault(self, entry)
    end
    return self
end



function Query:addAllEntries()
    for _, entry in ipairs(self.generator:getAllEntries()) do
        addDefault(self, entry)
    end
    return self
end



local function applyFilters(self, pick)
    local entry = pick.entry
    if Query:isInstance(entry) then
        return true -- don't apply filters to nested queries
    end
    local traits, chance = getTraits(self, entry), pick.chance

    for _, f in ipairs(self.filters) do
        local ok = f(entry, traits, chance)
        if not ok then
            return false
        end
    end
    return true
end


local function applyChanceAdjustment(self, pick)
    local entry = pick.entry
    if Query:isInstance(entry) then
        return pick -- don't apply adjustment to nested queries
    end
    local newChance = pick.chance
    local traits = getTraits(self, entry)

    for _, adjustChance in ipairs(self.chanceAdjusters) do
        newChance = adjustChance(entry, traits, newChance)
        assertPositiveNumber(newChance)
    end

    return newPick(pick.entry, newChance)
end



function finalize(self)
    if self:isEmpty() then
        umg.melt("Cannot finalize query! (There are no possible results.)")
    end
    local picks = self.picks
        :filter(function(pick) return applyFilters(self, pick) end)
        :map(function(pick) return applyChanceAdjustment(self, pick) end)
    self.picker = Picker(picks)
    self.outdated = false
end





return Query
