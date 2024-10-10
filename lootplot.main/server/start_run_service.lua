

local startRunService = {}


function startRunService.spawnSlots(ppos, team)
    lp.forceSpawnSlot(ppos:move(0,-4), server.entities.start_game_button, team)
    -- spawn text here

    spawnPerks(ppos, team)
end


