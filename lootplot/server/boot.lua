


umg.on("@createWorld", function(ent)
    -- create world plot
end)



umg.on("@playerJoin", function(clientId)
    server.entities.player(clientId)
end)


