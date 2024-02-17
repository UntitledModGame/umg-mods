


sync.autoSyncComponent("dimension", {
    type = "string",
    syncWhenNil = true
})



sync.proxyEventToClient("dimensions:entityMoved")
sync.proxyEventToClient("dimensions:entityMoveFailed")
sync.proxyEventToClient("dimensions:dimensionCreated")
sync.proxyEventToClient("dimensions:dimensionDestroyed")

