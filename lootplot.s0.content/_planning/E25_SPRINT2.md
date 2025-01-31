


## EARLY 2025 SPRINT TODO-LIST
------------
Hotfixes/balancing for our beta test.  
Round off the archetypes.
Touch ups for existing items; ensure emergence and depth.


## 17/JAN/2025 PARETO-PLANNING:

------------------------


- (((DONE))) Lootplot money-earned juice packets


- (((DONE))) Quit button should instead say: "Save and Quit" 


- (((DONE))) Change sack-items: Make them spawn cloud-slots, have them FLOATY.
^^^ These will ideally replace SHARDS.


- (((DONE))) More treasure-items:
Instead of spawning items, have more *direct* use-cases:
- (((DONE))) Diamond-chest: On UNLOCK: Spawn diamond slots  (KING-1)
- (((DONE))) Blue-chest: On UNLOCK: Give +20 points to all target items  (KING-1)




## Shop-balance refactor: 
- (((DONE))) Make stone-fruit cheap and COMMON, null-slots easy to get.
- Rework shop: 
    - (((DONE))) 2 food-shop slots
    - (((DONE))) 4 normal shop slots
- (((DONE))) Rare/Epic items can now spawn (INFREQUENTLY) in normal shop
- (((DONE))) Sack-items now spawn in shop


- (((DONE))) Make slot-spawner items rarer, and more expensive.


- (((DONE))) Worldgen consistency: Make it so only golden-slots spawn


- (((DONE))) Bug with cloud slots:
If you have negative money, you are unable to pick items from cloud slots


### Bonus mechanism:
- (((DONE))) Add `bonus` mechanism
- (((DONE))) Create `lp.addBonus`, `lp.get/setBonus`, etc.
- (((DONE))) Create `bonusGenerated` property + descriptions
- (((DONE))) Put `+X BONUS` UI in `lootplot.main`, next to global-mult.
- (((DONE))) use `lp.queue` to add bonus points. Its better for UX


- (((DONE))) Remove mana systems
- (((DONE))) Remove all `manaCost` items


- (((DONE))) JUICE: when collecting coin-packets, make a "ding" sound


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
Earn $2
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


## (SPIKE)
Make the destructive archetype better.
We already have some ideas for this at top of `destructive.lua`.
(REMEMBER: We want maximum synergies and strategy!!! Try to weave destructive archetype into other archetypes.
It SHOULDN'T be standalone.)


- Make ROTATE archetype more "global". Currently it's a bit... standalone.
Add a bunch more items that rotate stuff, BUT ALSO do other stuff.
(EG: generates points, AND rotates target items)
(REMEMBER: ITS **OKAY** IF STUFF IS OP. We actually *WANT* stuff to be OP.)



- SPIKE: Do something with feather-item (was removed due to mana changes)



## (SPIKE: PLANNING)
### PASSIVE ITEMS:
Why don't we have passive items?
IE: items that don't activate directly, but use `onUpdate` to have an effect.


## (SPIKE: PLANNING)
- Rework shards to do something else
(Ideally, we want them to *NOT* destroy themselves when used, lmao)


## (SPIKE)
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


- Change one-ball tutorial-text:
Instead of appearing on top of slots, we should spawn a button


- Have an end to the tutorial, (and maybe an exit-button?)

- Have mult in tutorial. 
(specifically; explain that putting mult BEFORE points is good!)

- Have BONUS in tutorial.
(specifically; explain that putting bonus BEFORE points is good!)

- Explain target-visuals in the tutorial
(dragonfruit item + potion, maybe?)


## (SPIKE)
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



- AGGREGATE display of points above each item:
So, say an iron-sword earns 20 points 6 times in a round. 
There should be blue text above it, that says "120".
(Same for mult.)
(^^^ TODO: not sure if this is a good idea. Might cause visual bloat and confusion...?)



