



local kill




function kill(ent)
    if ent:isOwned() then
        -- We only have authority to kill an entity if we own it
        umg.call("health:entityDeath", ent)
        ent:delete()
    end
end



sync.proxyEventToClient("health:entityDeath")



umg.on("health:entityDeath", function(ent)
    if ent.onDeath then
        ent:onDeath()
    end
end)



return kill
