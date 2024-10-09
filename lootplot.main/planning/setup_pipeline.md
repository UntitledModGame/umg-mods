


## ROUND -1  (perk-select)
player select perk.

Once selected, 3 items are spawned on the plot:
- perk-item
- worldgen-item
- doomclock-egg (ie gamemode item)


## ROUND 0  (WorldGen)
doomclock-egg spawns doomclock, next-round button, next-level button
perk-item spawns slots
worldgen-item spawns slots

## ROUND 1
Game begins!  
:)


-----


## Stuff to think about:

- How do we spawn the initial select-slots?
    - IDEA-1: Just spawn em in lootplot.main
    - IDEA-2: Spawn them in lootplot.worldgen; allows for cohesion and reuse

---

- When we select an item from a select-slot, what do we do?
Well, we obviously want to spawn the doomclock-egg, round-0
But.. how?
SIMPLE SOLUTION:
Just have a "start-round" button embedded in the plot.
Have some big text above the button, too: 
"PICK YOUR STARTING ITEM!"


