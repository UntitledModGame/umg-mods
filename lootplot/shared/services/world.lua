

local world = {}


--[[


TODO:

We probably dont need this....


]]

local entTc = typecheck.assert("entity")

function world.activateWorld(worldEnt)
    entTc(worldEnt)
    worldEnt.plot:foreachSlot()
end


function world.rerollWorld(worldEnt)
    entTc(worldEnt)
end


function world.rerollWorld(worldEnt)
    entTc(worldEnt)
end


return world

