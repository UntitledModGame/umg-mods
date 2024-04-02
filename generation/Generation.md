

# API Planning:
```lua

rng = RNGState()

gen = Generator(rng or nil)





-- defines an entry for the generation context
gen:defineEntry("mod:grass", {
    defaultChance = 1,
    traits = {
        overworld = true,
        plant = true,
        rarity = 5,
        level = 2
    }
})

-- add more entries:
gen:defineEntry("mod:ent_1", {...})
gen:defineEntry("mod:ent_ABC", {...})
gen:defineEntry("mod:ent_foobar", {...})
--[[
    ideally, these would work by tagging onto `@newEntityType`,
    and it would look for components deployed by the entity-type.

    If it matches some condition, then we should add the entity-type to our pool.
]]



local myQuery = gen:createQuery(rngObject or nil)


-- Create a generator query:
local query = gen:createQuery()

-- add some options to the query:
query:add("appl", 0.6)
query:add("bana", 0.4)
-- 60% x,  40% y.

-- generate 3 random entries:
local x1 = query()
-- x1 has 60% chance to be 'appl', 40% chance to be 'bana'




-- The real power comes with traits:
local query = gen:createQuery()
    :addEntriesWith("shrub") 
    -- adds ALL entries with `shrub` trait
    :addEntriesWith("overworld", "plant")
    -- adds entries with BOTH `overworld` trait AND 'plant' trait
    :addEntriesWith("overworld", "village") -- entries with overworld,village


-- We can also filter entries:
query:filter(function(entry, traits, chance)
    -- filters away entries that are less than level 2
    return traits.level > 2
end)


-- And we can adjust chances:
query:adjustChances(function(entry, traits, chance)
    if traits.rarity == LEGENDARY then
        -- increase likelihood of legendaries by 2 times.
        return chance * 2
    end
    return chance
end)



-- Queries can be nested:
local evil = gen:createQuery()
    :addEntriesWith("evil", "item")
local holy = gen:createQuery()
    :addEntriesWith("holy", "item")

local customQuery = gen:createQuery()
    :add(evil, 0.2) -- 20% chance for evil item 
    :add(holy, 0.8) -- 80% chance for holy item


```


