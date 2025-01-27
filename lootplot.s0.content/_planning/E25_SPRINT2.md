


## EARLY 2025 SPRINT TODO-LIST
------------
Hotfixes/balancing for our beta test.  
Round off the archetypes.
Touch ups for existing items; ensure emergence and depth.


## 17/JAN/2025 PARETO-PLANNING:

------------------------


- (((DONE))) Lootplot money-earned juice packets


- (((DONE))) Quit button should instead say: "Save and Quit" 


- Change treasure-bags: Make them spawn cloud-slots, have them FLOATY.
^^^ These will ideally replace SHARDS.

- IDEA: Maybe we should have treasure-bags that spawn *types* of items.  
EG:
- "Treasure-bag that spawns a REROLL item"
- "Treasure-bag that spawns a REPEATER item"
- "Treasure-bag that spawns a ROTATING item"
- "Treasure-bag that spawns a GRUBBY item"
^^^^ This allows players to take calculated risks when doing their build...?  
Hmmm... but such a mechanism would thin the item-pool. Maybe it's better to pick from a global pool of items, and just give the item GRUBBY, or give the item REROLL *after* its been generated...?




## Shop-balance refactor: 
- (((DONE))) Make stone-fruit cheap and COMMON, null-slots easy to get.
- Rework shop: 
    - 2 food-shop slots
    - 4 normal shop slots
- Rare/Epic items can now spawn in normal shop- BUT they are extremely rare.
- Treasure-items now spawn in shop
- Change reroll-slot to trigger on LEVEL-UP.


- AGGREGATE display of points above each item:
So, say an iron-sword earns 20 points 6 times in a round. 
There should be blue text above it, that says "120".
(Same for mult.)


- Worldgen consistency: Make it so only golden-slots spawn

- Bug with cloud slots:
If you have negative money, you are unable to pick items from cloud slots


### Bonus mechanism:
- Add `bonus` mechanism
- Create `bonusGenerated` property
- Put `+X BONUS` UI in `lootplot.main`, next to the global-mult count.


## Bonus UX:
Whenever points are earned with bonus, use `lp.queue` to add bonus points.
That way, the user can SEE visually how it actually works.
And it isn't just another confusing number.
(Might need to pass a flag or something so it doesn't enter infinite loop...? Not sure... OR, create a new function: `lp.addPointsRaw`, that doesn't invoke the mult/bonus mechanisms.)



- Create mineral shovel-items (Give +1 bonus)


- Make Star background better-  
back stars should be smaller and more transparent

- Change color of fog/clouds for different backgrounds


- Instead of saying "Round 7/6", It should say "LEVEL COMPLETE"


- ITEM: Lone-sword:
Shape: Rook-5
If this item isnt targetting any other items,
Give +5 mult

- ITEM:
Earn $1
GRUB-10

- ITEM: 
If money is less than $10, permanenly gain +8 points
Earns 8 points

- ITEM: Tumbling cat:
Same as copycat, but UP-3
Rotates when activated

- ITEM: Trigger = REROLL,PULSE
Permanently Gain +5 points when REROLLed.
Earns 5 points

- ITEM: golden knife
Destroy target items.
Earn $1 for each
(shape: UP-1)

- ITEM: Red lid:
If mult is below 1, add 4 mult



### Create Items interacting with BONUS:
(ONLY DO THIS TASK WHEN YOU ARE FEELING REFRESHED AND CREATIVE!!!)
- ITEM: lose bonus, increase mult
- ITEM-2: gain bonus, decrease mult
- ITEM-3: earn 30 points, decrease bonus by 1
- ITEM-4: If bonus is more/less than X, do XYZ
- BONUS-SHIELD: If bonus is negative, make bonus positive
- (Create more BONUS items; be creative; look for SYNERGIES.)


- Rename `lootplot.main` -> `lootplot.singleplayer`.
- Rename `lootplot.s0.content` --> `lootplot.s0`.
- Move `lootplot.s0.starting_items` --> `lootplot.s0`.
- Move doomclock, pulse-button, next-level-button to `lootplot.s0`
^^^ WARNING: Will require refactors to attributes. 
Perhaps we need to allow attributes to have default-values?


- Destroy all shop-slots after LEVEL-10.
This prevents the player ruining the game for themselves.
https://www.reddit.com/r/balatro/comments/1g0o0ax/wow_not_caring_about_the_endless_mode_made_the/

- Have an end to the tutorial, (and maybe an exit-button?)

- Have mult in tutorial. 
(specifically; explain that putting mult BEFORE points is good!)

- Have BONUS in tutorial.
(specifically; explain that putting bonus BEFORE points is good!)

- Explain target-visuals in the tutorial


## Perhaps create different activator items?
REMEMBER: We want maximum fun, and maximum synergies.
Our players have loved activator-items so far; lets lean into it.
- Activator-items:
- If target items dont earn any points, Pulse them
- If target items earn more than 5 points, Pulse them 
^^^ Idk if these are a good idea- we basically just want more synergy!


- Point balancing. Make the game easier; its too oppressive right now.


- For lootplot demo, instead of restricting items,
Make it so the player can only play 2 runs.

