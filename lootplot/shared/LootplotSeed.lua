

---@class lootplot.LootplotSeed: objects.Class
local LootplotSeed = objects.Class("lootplot:LootplotSeed")



local function stringToNum(str)
    return tonumber(str, 16)
end


local function numToString(num)
  return string.format("%x", num)
end



--local SEED_SIZE = 10 -- number of chars

local MAX_SEED = 2147483647

---@param seed? number|string
function LootplotSeed:init(seed)
    if not seed then
        seed = love.math.random(0, MAX_SEED)
    end
    if type(seed) == "string" then
        seed = assert(stringToNum(seed))
        assert(seed <= MAX_SEED, "Seed too big")
    end
    self.seed = seed

    self.rerollRNG = love.math.newRandomGenerator(seed)

    self.worldGenRNG = love.math.newRandomGenerator(seed + 1)

    self.miscRNG = love.math.newRandomGenerator(seed + 2)
end


function LootplotSeed:serializeToTable()
    ---@class lootplot.LootplotSeedSerialized
    local t = {
        seed = self.seed,
        rerollRNG = self.rerollRNG:getState(),
        worldGenRNG = self.worldGenRNG:getState(),
        miscRNG = self.miscRNG:getState(),
    }
    return t
end

---@param tab lootplot.LootplotSeedSerialized
function LootplotSeed:deserializeFromTable(tab)
    self.seed = tab.seed
    self.rerollRNG:setSeed(tab.seed)
    self.worldGenRNG:setSeed(tab.seed)
    self.miscRNG:setSeed(tab.seed)
    self.rerollRNG:setState(tab.rerollRNG)
    self.worldGenRNG:setState(tab.worldGenRNG)
    self.miscRNG:setState(tab.miscRNG)
end

function LootplotSeed:randomReroll(a,b)
    return self.rerollRNG:random(a,b)
end

function LootplotSeed:randomWorldGen(a,b)
    return self.worldGenRNG:random(a,b)
end

function LootplotSeed:randomMisc(a,b)
    return self.miscRNG:random(a,b)
end


---@cast LootplotSeed +fun(number?:number|string):lootplot.LootplotSeed
return LootplotSeed
