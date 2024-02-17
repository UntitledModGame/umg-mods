


sync.autoSyncComponent("dimension", {
    type = "string",
    syncWhenNil = true
})



sync.proxyEventToClient("spatial:entityMovedDimensions")
sync.proxyEventToClient("spatial:dimensionCreated")
sync.proxyEventToClient("spatial:dimensionDestroyed")

