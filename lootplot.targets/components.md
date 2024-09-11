


```lua

ent.shape = lp.targets.KingShape(1)


ent.target = {
    activate = function(selfEnt, ppos, targetEnt_or_nil) end,
    filter = function(selfEnt, ppos, targetEnt_or_nil) return bool end,
    description = "Clones target item",
    type = "ITEM" or "SLOT" or "NO_ITEM" or "NO_SLOT"
}


```
