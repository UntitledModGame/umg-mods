



local kill



if server then
-- Only the server has the authority to kill entities.

function kill(ent)
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
