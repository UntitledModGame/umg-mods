umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    return ent.ownerPlayer == clientId
end)
