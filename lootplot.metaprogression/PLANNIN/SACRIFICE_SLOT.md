

## IDEA:
Sacrifice-slot:

In order to unlock new items, we should have "sacrifice-slots",
that you can place items on top of.

The idea is, when you win the game, a `sacrifice-slot` appears.
Sacrificing your perk-item on the sacrifice-slot will unlock new stuff.

----------------------------------------

## How do we ensure good UX?
Make sure its clear HOW to unlock items.
Maybe best to showcase `?` item for locked perk-items?
(When hovered, showcase desciption showing HOW to unlock item.)
This works well for 2 reasons:
- 1: It gives a sense of discovery
- 2: It provides players with a goal/direction

REALLY IMPORTANT THING:
We *NEED* to make sacrificing perk-items VERY clear to the user!
Perhaps a big red arrow pointing towards the sacrifice-slot?
Also, have wavy "UNLOCK ITEMS" text above the sac-slot?


## Where/how do we define the unlock?  What restrictions do we have?
HMM:
Maybe we want bosses to spawn custom sacrifice-slots when they die?
Then, we can do stuff like:  
`Unlocked by killing [boss] with [starter-item]`

How do we define the unlock itself though?
```lua
unlock = {
    -- item-foo and item-bar need to be sacrificed.
    sacrifices = {"item_foo", "item_bar"}
}
```


## Design decisions:
Where should we define the unlocks?

Define sacrifice-slot inside of `lp.metaprogression`.
"What about custom-sacrifice-slots???"



