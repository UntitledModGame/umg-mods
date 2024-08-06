
umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    --[[
        in lootplot.main, 
        the "team" is just the clientId.
    ]]
    return ent.lootplotTeam == clientId
end)