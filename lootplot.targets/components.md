


```lua

itemEnt.shape = lp.targets.KingShape(1)


itemEnt.target = {
    activate = function(selfEnt, ppos, targetEnt_or_nil) end,
    filter = function(selfEnt, ppos, targetEnt_or_nil) return bool end,
    description = "Clones target item",
    type = "ITEM" or "SLOT" or "NO_ITEM" or "NO_SLOT"

    -- Transforms the pposList however you want.
    -- useful for stuff like: "targets a random item", "targets the cheapest item"
    transform = function(selfEnt, pposList) return { table.pick_random(pposList) } end
}


itemEnt.listen = {
    type = "ITEM",
    trigger = "REROLL" or "DESTROY" or "PULSE",
    filter = function(selfEnt, ppos, targetEnt)
        return isFood(targetEnt)
    end,
    activate = function(selfEnt, ppos, targetEnt)
        lp.modifierBuff(targetEnt, "price", 1)
    end
}
-- When a target pulses,   (trigger="PULSE")
-- if the target-item is food,   (filter)  
-- increase it's price by 1   (activate)




-- If this is true, items on this slot cannot listen to other items.
-- (Useful for shop-slots, null-slots, etc)
-- (Kinda similar to `canSlotPropagate` property)
slotEnt.isItemListenBlocked = true

```
