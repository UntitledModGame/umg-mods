

lp.defineTrigger("UPGRADE_TIER")


umg.defineEvent("lootplot.tiers:entityUpgraded")
sync.proxyEventToClient("lootplot.tiers:entityUpgraded")



components.defineComponent("tier")
sync.autoSyncComponent("tier", {
    type = "number",
    lerp = false,
})


