
umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    --[[
        in lootplot.singleplayer, 
        the "team" is just the clientId.
    ]]
    return ent.lootplotTeam == lp.getPlayerTeam(clientId)
end)
