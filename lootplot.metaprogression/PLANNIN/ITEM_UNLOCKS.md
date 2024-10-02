
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


### Indirect unlocks:
```lua
defineItem(item, {
    unlockable = {
        description = "Unlocked by beating the game with $0!",
        trigger = "WIN_GAME",
        filter = function()
            lp -- hmm, how do we do this?
        end
    }
    onActivate = func    
})
```


### Indirect unlocks try-2: EARLIER ASSUMPTIONS!!!!
Remember; Some assumptions can be done really beautifully, if the right stuff is assumed, and other stuff is left decoupled.
(See TABS it as an example.)

ASSUMPTION:
We only unlock items when we win a game.


```lua
defineItem(item, {
    unlockable = {
        description = "
        winGameWithItem = "my_item" -- if we win with `my_item` on the plot

        -- we can also do other stuff:
        reachLevelWithItem = {
            -- reach level 5 with iron axe
            level = 5,
            item = "iron_axe"
        }
    }
    onActivate = func    
})
```

TODO: what if we want more exotic forms of unlocks?