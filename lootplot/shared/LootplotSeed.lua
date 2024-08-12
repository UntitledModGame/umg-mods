

---@class lootplot.LootplotSeed: objects.Class
local LootplotSeed = objects.Class("lootplot:LootplotSeed")



local function stringToNum(str)
    return tonumber(str, 16)
end


local function numToString(num)
  return string.format("%x", num)
end



local SEED_SIZE = 10 -- number of chars

local MAX_SEED = 16 ^ SEED_SIZE

---@param seed? number|string
function LootplotSeed:init(seed)
    if not seed then
        love.math.random(0,MAX_SEED-1)
    end
    if type(seed) == "string" then
        seed = stringToNum(seed)
        assert(seed <= MAX_SEED, "?")
    end
    self.seed = seed

    self.rerollRNG = love.math.newRandomGenerator(seed)

    self.worldGenRNG = love.math.newRandomGenerator(seed + 1)

    self.miscRNG = love.math.newRandomGenerator(seed + 2)
end


function LootplotSeed:getSeed()
    return numToString(self.seed)
end

function LootplotSeed:randomReroll()
    return self.rerollRNG:random()
end

function LootplotSeed:randomWorldGen()
    return self.worldGenRNG:random()
end

function LootplotSeed:randomMisc()
    return self.miscRNG:random()
end


---@cast LootplotSeed +fun(number?:number|string):lootplot.LootplotSeed
return LootplotSeed
