

umg.defineEvent("lootplot.targets:targetActivated")

sync.proxyEventToClient("lootplot.targets:targetActivated")


umg.defineQuestion("lootplot.targets:canTarget", reducers.OR)
