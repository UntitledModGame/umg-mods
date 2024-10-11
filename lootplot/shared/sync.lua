sync.proxyEventToClient("lootplot:entityActivated")
sync.proxyEventToClient("lootplot:entityActivationBlocked")
sync.proxyEventToClient("lootplot:entitySpawned")
sync.proxyEventToClient("lootplot:entityDestroyed")

sync.proxyEventToClient("lootplot:itemMoved")

sync.proxyEventToClient("lootplot:entityTriggered")
sync.proxyEventToClient("lootplot:entityTriggerFailed")

sync.proxyEventToClient("lootplot:attributeChanged")


if client then

umg.on("lootplot:entityActivated", function(ent)
    if ent.onActivateClient then
        ent:onActivateClient()
    end
end)

umg.on("lootplot:entityDestroyed", function(ent)
    if ent.onDestroyClient then
        ent:onDestroyClient()
    end
end)

end

