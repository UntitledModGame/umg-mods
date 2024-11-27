

# LOOTPLOT


## Game overview:
Have a big 2d plane of items.

Items will interact with each other in wacky ways,
and generate points.

----





Ok. Lets go more in-depth:

# ROUNDS:
Every round, all slots are activated.
These will generate points, and do appropriate effects.

------

# OBJECTS:

## Slots:
Where items can be placed.
The player can expand their plot with new slots.
(See: `Creating-Slots` below)

Different slots can do different things:
- Blue slot: items pulses twice
- White slot: item is protected from death
- Pink slot: item is rerolled at the end of round
- Golden slot: ....
you get the idea.

## Creating-Slots
The player cannot purchase slots directly.
But, slots CAN be created by items when activated.
---->
For example:
```
On round end:
    destroy self, and spawn a slot above this tile.

When a neighbouring item is destroyed:
    10% chance to spawn a golden slot somewhere on the plot.

On round start:
    Spawn `Doomed` slots in a QUEEN shape
doomed: Dies after X rounds
```







## Items:
The things that go onto slots.
Can have a VAST set of effects. (Do a bunch of planning for this)
- Items have a `maxActivation` count, so infinite-loops dont occur

Items have the following structure:
```
shape,
trigger -> body
```
And then optionally, items can have a `debuff` and a `filter` value too.




# MECHANICS:
All of these mechanics should be tagged into / modified

- Items dying / being killed
- Items being created
- Reroll
- Items being activated
- Items being mutated:
    - Items changing triggers
    - Items changing augments
    - Items changing shape
- Items changing position (ie. being swapped)
- Items rotating
- Items being burned
    - Some items can get burned, and can change. 
        - Ie; meats --> cooked meats
        - Iron ores -> iron bars

And, central to all of this, should be *item placement.*
Think backpack-battles.
- Items triggering stuff in a rook, bishop, or king-like area
Areas could even be augmented by other items / effects




## Built-in Mods:
How about, `burn` mechanic is done and implemented as a built-in mod?
That is; built on top of `lootplot`?
This would serve as a great example to the community.
----->
We could also have `enemies` being a separate mod.
----->
^^^ This would make lootplot easier to mod in the future;
Since it's likely that the API would become more user-friendly.

## BURN MOD- Juice's ideas:
IDEA:
Have augments:
```
Flammable:
    When lit on fire, spreads fire in a plus-shape.

Burnable:
    Gets destroyed when lit on fire.
```
By default, all `PLANT` items are `flammable`.
Also, by default, all `PLANT` items 



# Shape ideas:
Shapes determine what items can target.
(See shapes.md)


# Cool synergy example:
Seed-item: Creates plants in a `king`-shape around itself.
Skull-item: kills all items in a `king`-shape around itself.
    For each item it kills, give +5 score





# Make sure to add *scaling.*
Part of the reason Balatro was so good was because big numbers go STONKS.
Add multipliers.
Add scaling to items.
Add open-ended combos.
Add long-term investment
## On the flip side: Ensure that late-game isn't *boring!*
In Bloons TD5, for example, late-game kinda gets boring once you get everything.
Design the game such that late-game is interesting, please! :)
## flip side 2: Try to avoid the board getting too busy late-game.
Make sure that items can be upgraded.
(If items can't be upgraded, the board will fill up and be too busy.)




# Augments:
"Augments" are entities that describe custom modifiers.
Augments can be applied to slots OR items.
(See `Augments.md`)



# Enemies!
Enemies are a REALLY cool idea for LootPlot.
Basically; enemies would just be regular items, that debuff the board.
For example:
    - debuff/fill up board slots
    - subtract points every round
    - steal money
    - duplicate themselves
    - apply modifiers to items

-------
## ENEMY IDEAS:
- Zombie: Will spawns copies of itself. Subtracts 5 points per round.
- Ghost: Nullifies slots. To kill a ghost, you must kill it's tombstone.
- Skeleton: Applies `doomed` debuff to a random item each round.
- SpiderRat: Steals 3 gold every round
- Salamander: Ignites all slots in a ROOK shape. 10% chance to destroy slot.
- Tophat: Convert random slots into BUY slots. 
    (Forces the player to buy back their own items)
- Monocle: Disables all `fiscal`-trait items in QUEEN shape.
----
## VISUALS:
We need to make a VERY CLEAR distinction between an enemy, and an item.
Maybe: a pulsing red outline around enemies?





# TRAIT IDEAS:
- Botanic (starter items. Very basic)
- Rulebender (anything meta)
- Deathly
- Cloneweaver
- Mechanical (gears, anything with rotation)
- Fiscal (anything that interacts with money)
- Serpent (anything that scales really well)



# MUSIC:
https://incompetech.com/music/royalty-free/music.html

Equatorial complex
Space Jazz
Mining by moonlight
Galactic rap
Dream catcher



# ASSETS:
For slots: https://pixeleart.itch.io/contact-icon-sets
