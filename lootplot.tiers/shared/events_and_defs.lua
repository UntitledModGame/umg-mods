

lp.defineTrigger("UPGRADE_TIER", "Item-Upgrade")


umg.defineEvent("lootplot.tiers:entityUpgraded")
sync.proxyEventToClient("lootplot.tiers:entityUpgraded")


components.defineComponent("tierUpgrade")


components.defineComponent("tier")
sync.autoSyncComponent("tier", {
    type = "number",
    lerp = false,
})


