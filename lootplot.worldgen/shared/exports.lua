---@class lootplot.worldgen
local worldgen = {}
assert(not lp.worldgen, "?")
lp.worldgen = worldgen



local spawnSlotsTc = typecheck.assert("ppos", "table", "number", "number", "string")

--- Spawns slots in a basic fashion
---@param ppos lootplot.PPos
---@param slotType any
---@param w number
---@param h number
---@param lootplotTeam string
---@param transform? fun(ent: Entity)
function worldgen.spawnSlots(ppos, slotType, w, h, lootplotTeam, transform)
    spawnSlotsTc(ppos, slotType, w, h, lootplotTeam)
    assert(server, "Can only be called on server-side")
    for dx=math.floor(-w/2 + 0.5), math.floor(w/2 + 0.5)-1 do
        for dy=math.floor(-h/2 + 0.5), math.floor(h/2 + 0.5)-1 do
            local p2 = ppos:move(dx,dy)
            if p2 then
                local slotEnt = lp.trySpawnSlot(p2, slotType, lootplotTeam)
                if not slotEnt then
                    umg.log.error("SPAWN: Couldnt spawn slot at pos: ", ppos)
                elseif transform then
                    transform(slotEnt)
                end
            end
        end
    end
end




--[[
WARNING:
dont add non-etype strings to these arrays!!!
or stuff will break BADLY.
]]

---@type objects.Array
worldgen.STARTING_ITEMS = objects.Array()
-- contains etype-names that are perks.

---@type objects.Array
worldgen.WORLDGEN_ITEMS = objects.Array()
-- contains etype-names that are worldgen-items.

---@type objects.Array
worldgen.GAMEMODE_ITEMS = objects.Array()
-- contains etype-names that are gamemode-items.



if server then

worldgen.IslandAllocator = require("server.IslandAllocator")

end

return worldgen
