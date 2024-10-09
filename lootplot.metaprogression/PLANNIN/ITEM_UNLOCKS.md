
# Item unlock planning:

Core goals of the API:
- Be SIMPLE to use
- Dont have unneccessary layers/abstractions
- Easy to unlock all items for a run (eg for pvp run)


---

### FULL API PLANNING:
```lua
lp.metaprogression.unlock("lootplot.s0.content:my_apple")
lp.metaprogression.see("lootplot.s0.content:my_apple")

lp.metaprogression.setStat("stat", val)
lp.metaprogression.getStat("stat", val)

local bool = lp.metaprogression.isLocked("lootplot.s0.content:my_apple")
local bool = lp.metaprogression.isSeen("lootplot.s0.content:my_apple")

lp.metaprogression.tryUnlock(plot, selfTeamId)

local plotData = lp.metaprogression.getPlotData(plot)
plotData.totalCounts["item"]
plotData.counts["item"] -- where `lootplotTeam == selfTeamId`

-- Call this in lp.main
lp.metaprogression.unlockEverything()

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
"Unlocked by winning using all 3 cats"

I think the "cleanest" way we can implement this
is to have a `lp.metaprogression.tick(plot)` method,
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

^^^ BIG DOWNSIDE! this is very inefficient.  
Imagine having 100 unlockable items, with a 40x40 plot.  
That would be `40*40*100 = 160_000` iterations!!!

IDEA:  
Lets pre-compute the item and slot counts.

Then, we add a couple of lil helper parameters:
```lua
shouldUnlock = function(plot, itemCounts, slotCounts)
    return itemCounts["copycat"] >= 20
end,
description = "Unlocked by having 20 copycats"
```
And we would pass these in via:
```lua
lp.metaprogression.tick(plot)
-- ^^^ this function would pre-compute itemCounts and slotCounts
```

BUT THIS KINDA SUCKS!
Because itemCounts and slotCounts are kinda like, "meh"  
they are kinda weird variables to pass in.  
Ideally, we would want to pass arbitrary data

EG:
"bosses" mod. We may want to pass in a list of bosses 
that were defeated throughout the run.

---

## THE GOLDEN SOLUTION:
The IDEAL solution is to have NO arguments to the `shouldUnlock` functon.  
ie just keep global upvalues that store the item/slot counts.

This is super nice; since `lp.content.s0` can manage the static objects.
```lua
local itemCounts = ... -- automatically managed upvalue


defineItem(item, {
    unlockOnTick = {
        shouldUnlock = function()
            return itemCounts["copycat"] >= 20
        end,
        description = "Unlocked by having 20 copycats"
    }
    onActivate = func    
})
```

*The issue*, is that we may have multiple plots!!!
This is why we kinda need to pass `plot` in.

## CRUX OF ISSUE:
All in all, the big crux of the issue, is that the whole of `lootplot`
has no well-defined "plot state"; ie, there could be 50 plots, or 1 plot.

This is nice, because when entities do an action, the backend can just check what plot the entity resides in.
The entity doesnt need to manage plots, or even know about plots!

**BUT**... item entity-types are static-globals; they have NO plot :/

So, that's the real crux of the issue.
We want to take data from plots, and move it to an unknown context.


## IDEA: `StatCollector` objects:
```lua
local obj = StatCollector(plot)
obj:add("value", 1)
```


## FINAL IDEA:
Just KISS.

Either count ALL of the items, no matter what,
OR, count items where `lp.canPlayerAccess(item, clientId) == true`


## FINAL-2 IDEA:

FOR `plotData`:
Count ALL slots.
But count only accessible items.

API:
```lua
defineItem(item, {
    unlock = {
        trigger = "WIN" or "ON_UPDATE",
        shouldUnlock = function(plot, plotData)
            return plotData.itemsCounts["copycat"] >= 20
        end,
        description = "Unlocked by having 20 copycats",
    },
    onActivate = func    
})

```


# IDEA:
Keep `lp.metaprogression` simple.
Dont have any weird, custom components.

Call `lp.metaprogression.unlock(item)` from future systems/mods.

---

Idea:   
We dont need to query 100% of the time when seeing if we unlock items!!
Consider unlocks:
```
- Win using [starter-item]
- Beat [boss] using [starter-item]
- [Do something] using [starter-item]
```

The reason this is great, is because we *only need to apply the checks if starter-item has been previously seen.*  
IE: consider:  
- "Obtain exactly 42 gold using pool-perk-item."
^^^ Isnt this ineffiicent?
NO! Because we only need to check every frame, 
IFF the player has obtained `pool-perk-item` during the run!

## SUPER NICE API:
```lua
defineItem(item, {
    unlock = unlockByWinningWith("perk_item")
    onActivate = func    
})
```

This is SUPER NICE.

---

another thing to think about:
How is item-unlock data propagated from server -> client?

IDEA: Maybe its auto-synced?

# DRAFT: Internal metaprogression state:
```lua

lp.metaprogression.startRun(plot)
lp.metaprogression.updateRun(plot)
lp.metaprogression.winRun(plot)

```

# FINAL-3 "good enough" PLAN:
- Add function: `lp.metaprogression.winGame(plot)`
- Create `unlock` API (keep it simple!)
- Define unlocks in `lootplot.s0.content`
- Define a helper function: `unlockByWinningWith("perk_item")`
- ITEMS SHOULD BE UNLOCKED BY DEFAULT!!! `lp.main` should lock them!

`unlock` shcomp:
```lua
unlock = {
    requiredItems = {"foo", "bar"},
    description = "Win using foo and bar items!"
}
```

