

## SLOTS:
Do we need these functions...?
Hmm... maybe we should keep some of them..?

But I also think that some of them should be global helpers instead
```lua
function slots.canAdd()
function slots.tryAdd()
function slots.canRemove()
```

OK.
lets think: How would we implement a slot that can only take {trait} items?

Definitely should be emitting a question.
I guess the question is:
WHERE should we emit said question from?
This is what this file would be great for.

Do we want to allow blocking of removal..?
I feel like thats a bit weird... idk

Are there any valid use-cases for blocking item-removal?
(Not really, I feel like!)




## UI planning:
(A)  in lootplot.base, as a generic scene for lootplot.
If mods wanna add to the scene, tag into some api deployed by lootplot.base

(B)  in lootplot.main. We would then add the "core buttons" directly inside of this scene.
DOWNSIDE: The "core-buttons" would need to be duct-taped on kinda jankily.

(C)  in some base-mod; like uibasics mod.
Tag into some uibasics API to add elements to the scene.

---

I was considering option-C for this...
But Xander recommended option-B.
I think option-B is the most assumptionless, tbh...

ALSO: Another reason why opt-B is the best, is because most of the really
"complex" UI is going to be within the main-gamemode, NOT within the base-gamemode.
In general, its just more assumptionless and better.



activate



## Game shitty-ness:
For `lootplot.main` specifically:  
We *need* `MainGame` to be able to be accessed on BOTH server AND client.
We will need syncing for this...   
Should we have some sort of auto-syncing feature...?  
Could bind `Game` to an entity..?  

Also; it's quite unweidly using a big, monolithic "Game" class like this.
Perhaps rename to `Context`...?

ALSO: Another "big" problem that hasn't really been discussed;
What about fields/data that need to be synced up between cl/serv???  
Or, other obscure fields that impact the game?  
(Like, `luck`, for example?)  
--->>  
IDEA: Change `Game` class to `Context`.  
Store NO data inside of `Context`; instead, store all data inside of `world`
entity; or inside of the `player` entity, if relevant.
(This way, we get the niceness of syncing, (via `sync.autoSyncComponent`)
AND, we get a bit of standardization kinda.)

### TODO...?
- Remove `money` and `points` services; inline API inside of `exports.lua`?
- Rename `Game` to `Context`...?

## To think about:
How do we "start" the game?  
Used to use `lp.startGame()`: But we are now using context-objects.  
Maybe we just keep the same naming; but rename `lp.Class` to `lp.Context`.

### OK:
Now, the "awkward" thing about all of this, is that we are now gonna
have a singleton class.
Perhaps it'd then be better to pass in a static "service", 
as opposed to a class?

## IMPL:
We want data to be saved within runs. (ie be persistent)  
With this in mind, we ABSOLUTELY want to represent world-data as inside 
of ents.
I guess the main question is:
How do we sync this data?
IDEA:  We should have a singular component: `ent.worldData` or something,
that stores world-data, specific to this instance of lootplot.
(This way we dont bloat the comp namespace)

Still- its a bit messy having to kinda "yeet" the entity over or something.


## Syncing:
Maybe we should auto-create a world-entity in lootplot.base, 
and automatically pass it between cl/serv?

The world-entity would *contain* the context.
This would remove the issue of having to pass the context between cl/serv.

"Doesn't this assume that we can only have 1 world context ent???"
(Yes, but this is already the case: `lp.getContext()`)







## OKAY: World-state planning:
Keep a `state` object in world:
```lua
worldEnt.lootplotWorld = true
worldEnt.data = {
    points = X,
    requiredPoints = X,
    money = X,
    turn = X,
    level = X
}
```

PROBLEM:  
We need to somehow always have a *singular* entity.
Lets define some functions for this.

List of functions:
```lua

-- shared:
lp.overrides.getMoney()
lp.overrides.getPoints()

-- clientside:
goNextRound() -- sends a packet

-- serverside:
syncValue("money" or "points" or "round", X)
lose() -- shows "You lost!" screen
nextLevel()
nextRound()

lp.overrides.setMoney()
lp.overrides.setPoints()

```





# Slot / activation planning:
We have a few questions.

- When a slot activates, should the item in the slot also activate?
    - IDEA: Pass in `ppos` instead of an entity to activate?
    - (New api: `lp.activateEntity`, `lp.activate(ppos)`)
- Do we need `lp.[detach/attach]Item`?
    - hmm, mayb not.

Currently, we have two "layers" to represent both "items" and "slots".
How about we make layers "generic"; such that future mods can add their
own custom layers?
like:
```lua
--plot ctor:
self.layers = {
    ["slot"] = Grid(),
    ["item"] = Grid(),
    -- ... can define custom ones too!
}
```
And then a component upon the entity:
```lua
ent.layer = "slot" or "item"
```

This also works great, because it means that we can make `Plot:set` more generic. (only need one sync mechanism.)

ALSO:
It means that entities CANNOT be bound to more than one layer type at once,
which is great!



-------------


# Warts that still need to be worked out:

How should trigger propagation be done?
We could just do it at the very base level...
As in, propagate at the call site itself.


----------


How are we going to do shop slots?

I am still very torn;
On one hand we want to decouple components as much as possible,
But on the other hand, there is a whole family of components that are very closely related-
```
hasAccess
-->
canMove
canDestroy
```

There's also an issue with current bool properties:
It's unclear whether the properties are applied to the player actions,
Or whether they are applied to the system.

For example:
`canMove` -->
Does this imply that only the player can't move it?
Orders this imply that the item can't move at all...?





## IDEA:
We make a big assumption about player interaction.
Assume that all player interaction falls under the following things:
```
moving items
destroying/selling items
using buttons on items
```

From there we can have a highly unified API:
```lua
lp.canPlayerAccess(ent,clientId)

umg.answer("lootplot:canPlayerAccess", function(ent, clientId)end)

defineBasicBoolean("canPlayerAccess", "baseCanPlayerAccess")
```

(We will also have a bool properly: `canPlayerAccess`)
The selection service will need to accommodate for this.

---

What's really beautiful about this, is that enemies can reuse this api in the future.
Also this makes multiplayer lot easier.







