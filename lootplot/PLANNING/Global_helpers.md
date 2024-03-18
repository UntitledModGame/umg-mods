
# Global helpers:

```lua

activate(ent) -- activates an entity

destroy(ent)

sell(ent)
rotate(ent, angle=math.pi/2) -- rotates by an angle.

setSlot(ppos, slotEnt) -- sets a slot

swap(item1, item2) -- swaps positions of 2 item entities
move(item1, ppos) -- moves an item to ppos. Will overwrite
detach(ent) -- removes an entity from a plot. position info is nilled.

update(ent, ppos) -- updates the .plot, .slot values for `ent`.
-- This should be called whenever `ent` changes position.

cloned = clone(ent)



local item = spawn(itemEType) -- tries to spawn an item at ppos



ppos = above(ppos) -- gets the ppos ABOVE this ppos
_,_,_ = below(ppos), left(ppos), right(ppos)
item = getItem(above(ppos))
slot = getSlot(above(ppos))


-- looping over ents:
local ents = touching(ent) -- gets all ents that we are touching:

touching(ent):loop(function(ppos)
    -- loops over all neighbour positions, `ppos`
end)

-- We can also use filter API, w/ chaining:
touching(...)
    :filter(func)
    :items() -- ppos --> item
    :loop(function(itemEnt)
        -- loops over all neighbour item ents. 
        -- Note: item
    end)


-- other ideas:
touching:filterTraitMatch(ent.traits) -- filters on matching trait(s)
-- (^^^ definitely hardcode common methods like this)


-- STRETCH / NYI:
burn(ppos)




```


