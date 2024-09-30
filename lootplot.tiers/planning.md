

# `lootplot.tiers` mod



## Components / events:
```lua

ent.onUpgradeTier = function(ent, oldVal, newVal)
    ...
end

umg.call("lootplot.tiers:upgradeTier", ent, oldVal, newVal)

ent.tieredProperties = {
    --[[
    tier-1:  $1
    tier-2:  $3
    tier-3:  $9
    ]]
    moneyGenerated = {1, 3, 9}
}
```


# IDEA: Unify under `.tiers` component.
```lua

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


