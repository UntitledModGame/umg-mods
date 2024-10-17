
--[[

sync.syncComponent(ent, compName)


Manually syncs a component on serverside.
(Doesn't care about delta compression or nils)


]]



umg.definePacket("sync:syncComponent", {
    --          entity  comp_name  serialization-data
    typelist = {"entity", "string", "string"}
})




if client then

client.on("sync:syncComponent", function(ent, compName, compData)
    local compValue, err = umg.deserializeVolatile(compData)
    if (not compValue) and err then
        umg.log.fatal(err)
    else
        ent[compName] = compValue
    end
end)

end





if server then

local syncComponentTc = typecheck.assert("entity", "string")
local function syncComponent(ent, compName)
    syncComponentTc(ent, compName)

    local data = umg.serializeVolatile(ent[compName])
    server.broadcast("sync:syncComponent", ent, compName, data)
end

return syncComponent

end


