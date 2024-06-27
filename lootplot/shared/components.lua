properties.defineNumberProperty("buyPrice", {
    base = "baseBuyPrice",
    default = 2,
})

sync.autoSyncComponent("buyPrice", {
    type = "number",
    lerp = false,
})

properties.defineNumberProperty("sellPrice", {
    base = "baseSellPrice",
    default = 1,
})

sync.autoSyncComponent("sellPrice", {
    type = "number",
    lerp = false,
})
