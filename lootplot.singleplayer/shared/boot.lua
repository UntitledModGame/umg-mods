


umg.on("@playerJoin", function(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end)



umg.on("@tick", function(dt)
    if server then
        local run = lp.main.getRun()
        if run then
            run:sync()
            run:tick(dt)
        end
    end
end)



--[[

OLD CODE:
Level spawning requirements:

    [r.UNCOMMON] = 2, -- UNCOMMON items spawn at this level
    [r.RARE] = 4, -- RARE items start spawning at this level
    [r.EPIC] = 7, -- (etc)
    [r.LEGENDARY] = 12,
    [r.MYTHIC] = 16,

]]

