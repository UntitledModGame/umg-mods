
--[[

Global LOOTPLOT helper methods.




]]

local lootplot = {}

function lootplot.get(ppos)
    -- gets an item at a ppos
    return ppos.plot:get()
end

itemEnt = get(ppos)

activate(ppos)
activate(ent) -- <<< alternative usage.

destroy(ppos) -- kills item at ppos
destroySlot(ppos) -- kills slot at ppos!

burn(ppos)
sell(ppos) -- sells item at plotPos
rotate(ppos, angle=math.pi/2) -- rotates item by an angle.

trySpawn(ppos, itemEType)


-- directly sets/gets an item
set(ppos, itemEnt)
get(ppos)



return lootplot
