

lp.defineAttribute("ROUND")
-- current round number

lp.defineAttribute("NUMBER_OF_ROUNDS")
-- The number of rounds allowed per level
-- (should generally be kept constant.)
-- if ROUND > NUMBER_OF_ROUNDS, lose.

lp.defineAttribute("REQUIRED_POINTS")
-- once we reach this number, we can progress to next level.





umg.on("@playerJoin", function(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end)



umg.on("@tick", function()
    if server then
        local run = lp.main.getRun()
        if run then
            run:sync()
            run:tick()
        end
    end
end)



local r = lp.rarities
lp.rarities.configureLevelSpawningLimits({
    -- Rare items can only spawn after level 3.
    -- epic items after level 5... etc etc.
    [r.RARE] = 3,
    [r.EPIC] = 5,
    [r.LEGENDARY] = 9,
    [r.MYTHIC] = 14,
})
