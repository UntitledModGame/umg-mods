
---@meta

assert(not lp.worldgen, "?")
lp.worldgen = {}



local spawnSlotsTc = typecheck.assert("ppos", "table", "number", "number", "string")

--- Spawns slots in a basic fashion
---@param ppos lootplot.PPos
---@param slotType any
---@param w number
---@param h number
---@param lootplotTeam string
function lp.worldgen.spawnSlots(ppos, slotType, w, h, lootplotTeam)
    spawnSlotsTc(ppos, slotType, w, h, lootplotTeam)
    assert(server, "?")
    for dx=math.floor(-w/2 + 0.5), math.floor(w/2 + 0.5)-1 do
        for dy=math.floor(-h/2 + 0.5), math.floor(h/2 + 0.5)-1 do
            local p2 = ppos:move(dx,dy)
            if p2 then
                local ok = lp.trySpawnSlot(p2, slotType, lootplotTeam)
                if not ok then
                    umg.log.error("SPAWN: Couldnt spawn slot at pos: ", ppos)
                end
            end
        end
    end
end


---@type objects.Array
lp.worldgen.STARTING_ITEMS = objects.Array()
-- contains etype-names that are perks.
--[[
WARNING:
dont add non-etypes to this array!!!
or stuff will break
]]





--[[



TODO:


Add support for worldgen items here.
Ie, items that generate random islands, and such.




]]

