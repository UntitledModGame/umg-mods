

--[[
==================================================
    Generation test suite
==================================================
]]




local LegacyGenerator = require("shared.LegacyGenerator")



local gen = LegacyGenerator()

local function defTestEntry(name, traits, chance)
    local traitHash = {}
    for _,v in ipairs(traits) do
        traitHash[v] = true
    end
    gen:defineEntry(name, {
        defaultChance = chance,
        traits = traitHash
    })
end


local function isSimilar(float1, float2)
    local diff = math.abs(float1-float2)
    return diff < 0.005
end

local function normalize(tabl)
    local total = 0
    for k,v in pairs(tabl) do
        total = total + v
    end
    for k,v in pairs(tabl) do
        tabl[k] = tabl[k] / total
    end
end


local TEST_COUNT = 10000000

local function expect(query, distribution)
    local picks = {--[[  [pick] -> count  ]]}
    for _=1, TEST_COUNT do
        local e = query()
        picks[e] = (picks[e] or 0) + 1
    end
    normalize(picks)

    for k,v in pairs(distribution) do
        if not isSimilar(v, picks[k]) then
            print("EXPECTED:\n",umg.inspect(distribution))
            print("REAL NORMALIZED PICKS:\n",umg.inspect(picks))
            umg.melt("Expect failed. See log.")
        end
    end
end







defTestEntry("grass", {"grass"})
defTestEntry("dirt", {"earth"}, 0.5)

defTestEntry("tree", {"grass", "earth"})

defTestEntry("orc", {"hell"})
defTestEntry("goblin", {"hell"})





do
local q = gen:createQuery()
    :addEntriesWith("grass", "earth")

expect(q, {
    tree = 1
})
end





do
-- test combined:
local q = gen:createQuery()
    :addEntriesWith("grass")
    :addEntriesWith("earth")

expect(q, {
    dirt = 1/5,
    grass = 2/5,
    tree = 2/5
})
end



do
-- test nested query:
local q = gen:createQuery()
    :addEntriesWith("hell")
local q2 = gen:createQuery()
    :addEntriesWith("grass")

local query = gen:createQuery()
    :add(q, 0.4)
    :add(q2, 0.6)

expect(query, {
    goblin = 2/10,
    orc = 2/10,
    grass = 3/10,
    tree = 3/10
})
end







do
-- test filter:
local q = gen:createQuery()
    :addEntriesWith("earth")
    :addEntriesWith("grass")
    :filter(function(entry, traits, chance)
        return not traits.earth
    end)

expect(q, {
    grass = 1
})
end




do
-- test adjust chances::
local q = gen:createQuery()
    :addEntriesWith("earth")
    :addEntriesWith("grass")
    :adjustChances(function(entry, traits, chance)
        if traits.grass then
            return chance * 2
        end
        return chance
    end)

expect(q, {
    tree = 4/9,
    grass = 4/9,
    dirt = 1/9
})
end



do
-- test chance overwrite:
local q = gen:createQuery()
    :add("foo", 0.1)
    :add("bar", 1)
    :add("foo", 9)
expect(q,{
    bar=1/10,
    foo=9/10
})
end
