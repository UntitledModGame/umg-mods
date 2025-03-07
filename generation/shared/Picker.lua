
--[[

OK:
I'm not gonna fakken lie, I'm actually NOT ENTIRELY SURE HOW THIS WORKS.
Basically, it's a highly efficient discrete-random-sampling algorithm,
using an algorithm called the "Alias method":
https://en.wikipedia.org/wiki/Alias_method

Code taken from:  https://gist.github.com/RyanPattison/7dd900f4042e8a6f9f23
(Released into public domain, per Ryan's request)

Ok::::
After some "better" research, I found an excellent source 
with a very intuitive explanation:
https://www.keithschwarz.com/darts-dice-coins/

]]

---Picker is responsible of picking weighted items quickly at O(1) time
---multiple times.
---
---If the item list is dynamic or it only needs be picked once then consider
---`generation.pickWeighted` or `generation.pickWeightedPlanar`.
---@class generation.Picker: objects.Class
local Picker = objects.Class("generation:Picker")

---@param items any[]
---@param weights number[]
function Picker:init(items, weights)
    self.entryList = table.shallowCopy(items)

    local total = 0
    for _,v in ipairs(weights) do
        assert(v >= 0, "all weights must be non-negative")
        total = total + v
    end

    local normalize = #weights / total
    local norm = {}
    local small_stack = {}
    local big_stack = {}

    for i,w in ipairs(weights) do
        norm[i] = w * normalize
        if norm[i] < 1 then
            table.insert(small_stack, i)
        else
            table.insert(big_stack, i)
        end
    end

    local prob = {}
    local alias = {}
    while small_stack[1] and big_stack[1] do -- both non-empty
        local small = table.remove(small_stack)
        local large = table.remove(big_stack)
        prob[small] = norm[small]
        alias[small] = large
        norm[large] = norm[large] + norm[small] - 1
        if norm[large] < 1 then
            table.insert(small_stack, large)
        else
            table.insert(big_stack, large)
        end
    end

    for _, v in ipairs(big_stack) do
        prob[v] = 1
    end
    for _, v in ipairs(small_stack) do
        prob[v] = 1
    end

    self.alias = alias
    self.prob = prob
    self.n = #weights
end

if false then
    ---@param items any[]
    ---@param weights number[]
    ---@return generation.Picker
    function Picker(items, weights) end ---@diagnostic disable-line: cast-local-type, missing-return
end


local function pickIndex(self, rand, rand2)
    -- 0 <= num <= 1
    local index = math.floor(rand * self.n) + 1
    if rand2 < self.prob[index] then
        return index
    else
        return self.alias[index]
    end
end


--[[
    The Vose Alias method requires TWO random variables to work properly.
]]
---@param rng {random:fun(self:any):number}?
---@return any
function Picker:pick(rng)
    local rand1, rand2
    if rng then
        rand1 = rng:random()
        rand2 = rng:random()
    else
        rand1 = math.random()
        rand2 = math.random()
    end

    local i = pickIndex(self, rand1, rand2)
    return self.entryList[i]
end




return Picker



