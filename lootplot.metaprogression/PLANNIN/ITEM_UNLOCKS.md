
# Item unlock planning:

Core goals of the API:
- Be SIMPLE to use
- Dont have unneccessary layers/abstractions
- Easy to unlock all items for a run (eg for pvp run)


---

### SIMPLE API PLANNING:
```lua
lp.metaprogression.unlock("lootplot.content.s0:my_apple")
lp.metaprogression.see("lootplot.content.s0:my_apple")

local bool = lp.metaprogression.isLocked("lootplot.content.s0:my_apple")
local bool = lp.metaprogression.isSeen("lootplot.content.s0:my_apple")
```


### Indirect unlocks try-2: EARLIER ASSUMPTIONS!!!!
Remember; Some assumptions can be done really beautifully, if the right stuff is assumed, and other stuff is left decoupled.
(See TABS it as an example.)

ASSUMPTION:
We only unlock items when we win a game.
This ^^^ works well to reward players for winning.

```lua
defineItem(item, {
    unlockOnWin = {
        shouldUnlock = function(plot)
            return helper.plotHasItem("perk_item")
            -- Unlock, iff we win with `perk_item` on the plot
        end
        -- NOTE: We should somehow be doing load-time validation, 
        -- to check if `perk_item` is a valid item!
        -- (HMM, not sure if thats possible tho, maybe not worth it)

        description = "Unlocked by winning the game with `Perk Item`"
    }
    onActivate = func    
})
```


## What about exotic forms of unlocks?

EG:
"Unlocked by having 20 copycats"
"Unlocked by having a negative balance"
"Unlocked by destroying all shop slots"
"Unlocked by destroying all sell slots"
"Unlocked by winning with all 3 

I think the "cleanest" way we can implement this
is to have a `lp.metaprogression.checkUnlocks(plot)` method,
or something.
The system will just loop over all unlock-types, and do a crude check.
```lua
defineItem(item, {
    unlockOnTick = {
        shouldUnlock = function(plot)
            local count = 0
            plot:foreachItem(function(item)
                if item:type()=="copycat" then
                    count = count + 1
                end
            end)
            if count >= 20 then
                return true
            end
        end,
        description = "Unlocked by having 20 copycats"
    }
    onActivate = func    
})
```
