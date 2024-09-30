

# `lootplot.tiers` mod
Allows items to be upgraded.


## Components / events:
```lua

umg.call("lootplot.tiers:tierUpgraded", ent, oldVal, newVal)


ent.tierManager = {
    onUpgrade = function(ent, oldVal, newVal)
        ...
    end,
    description = "Increases money generated"
    properties = {
        ...
        moneyGenerated = {1, 3, 9}
    }
}
```


## Systemic interactions:

Consider penguin from SAP:
"Give all tier-2 pets +1,1"

This is FANTASTIC, because it encourages upgrading units!!!
We should do the same thing with octopus, maybe?

Octopus:
Triggers all target tier-2 items

