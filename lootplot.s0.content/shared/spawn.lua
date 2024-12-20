

local spawn = {}


local spawnSlotsTc = typecheck.assert("ppos", "table", "number", "number", "string")

---@param ppos lootplot.PPos
---@param slotType any
---@param w number
---@param h number
---@param lootplotTeam string
function spawn.spawnSlots(ppos, slotType, w, h, lootplotTeam)
    spawnSlotsTc(ppos, slotType, w, h)
    assert(server, "?")
    for dx=math.floor(-w/2 + 0.5), math.floor(w/2 + 0.5)-1 do
        for dy=math.floor(-h/2 + 0.5), math.floor(h/2 + 0.5)-1 do
            local p2 = ppos:move(dx,dy)
            if p2 then
                lp.trySpawnSlot(p2, slotType, lootplotTeam)
            end
        end
    end
end




return spawn

