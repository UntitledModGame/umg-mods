
local Picker = require("shared.Picker")

---@class generation.Query: objects.Class
---@operator call:any
local Query = objects.Class("generation:Query")

---@class generation._Pick
---@field package chance number
---@field package entry any

local ARGS = {"rng", "generator"}
---@param args {rng:love.RandomGenerator,generator:generation.LegacyGenerator}
function Query:init(args)
    typecheck.assertKeys(args, ARGS)

    -- you won't need to modify ANY of these fields outside this module.
    self.rng = args.rng
    self.generator = args.generator

    ---@type table<any, generation._Pick>
    self.seenPicks = {}
    self.picks = objects.Array(--[[
        {chance=X, entry=X}
    ]])

    self.filters = objects.Array()
    self.chanceAdjusters = objects.Array()

    self.outdated = true
    self.picker = nil

    self.nestedQueries = objects.Set()

    self.bufferedEntries = objects.Array()
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
        ---@cast result generation.Query
        return result()
    end
    return result -- else, its an entry.
end

---@return boolean
function Query:isEmpty()
    return #self.picks <= 0
end

---@return generation._Pick
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

---@param entry_or_query any
---@param chance number
---@return generation.Query
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

---@param f fun(entry:any,traits:table<string,any>,chance:number):boolean
---@return generation.Query
function Query:filter(f)
    self.filters:add(f)
    markOutdated(self)
    return self
end

---@param f fun(entry:any,traits:table<string,any>,chance:number):number
---@return generation.Query
function Query:adjustChances(f)
    self.chanceAdjusters:add(f)
    markOutdated(self)
    return self
end




local function getTraits(self, entry)
    return self.generator:getTraits(entry)
end

---@param self generation.Query
local function addDefault(self, entry)
    local chance = self.generator:getDefaultChance(entry)
    self:add(entry, chance)
end

---adds entries with ALL of the traits listed.
---@param ... string
---@return generation.Query
function Query:addEntriesWith(...)
    self.bufferedEntries:add({...})
    return self
end



function Query:addAllEntries()
    -- empty table indicates ALL possible entries.
    self.bufferedEntries:add({})
    return self
end


function Query:refresh()
    --[[
    refreshes the query, causing the chance-adjusters and filters
    to be applied again.
    
    Useful when our filters/chance-adjusters tag onto global state.
    ]]
    self.outdated = true
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

---@param self generation.Query
---@param pick generation._Pick
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

---@param self generation.Query
local function finalizeBufferedEntries(self)
    for _, bufferedEntry in ipairs(self.bufferedEntries) do
        if #bufferedEntry > 0 then
            local entries = self.generator:getEntriesWith(unpack(bufferedEntry))
            for _, entry in ipairs(entries) do
                addDefault(self, entry)
            end
        else
            for _, entry in ipairs(self.generator:getAllEntries()) do
                addDefault(self, entry)
            end
        end
    end

    self.bufferedEntries:clear()
end

---@param self generation.Query
function finalize(self)
    if self.bufferedEntries:size() > 0 then
        finalizeBufferedEntries(self)
    end

    if self:isEmpty() then
        umg.melt("Cannot finalize query! (There are no possible results.)")
    end
    local picks = self.picks
        :filter(function(pick) return applyFilters(self, pick) end)
        :map(function(pick) return applyChanceAdjustment(self, pick) end)
    local items = {}
    local weights = {}

    for _, pick in ipairs(picks) do
        items[#items+1] = pick.entry
        weights[#weights+1] = pick.chance
    end
    self.picker = Picker(items, weights)
    self.outdated = false
end





return Query
