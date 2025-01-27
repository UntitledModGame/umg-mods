


## EARLY 2025 SPRINT TODO-LIST
------------
Hotfixes/balancing for our beta test.  
Round off the archetypes.
Touch ups for existing items; ensure emergence and depth.


## 17/JAN/2025 PARETO-PLANNING:

------------------------


- Lootplot money-earned juice packets


- Quit button should instead say: "Save and Quit" 


## Shop-balance refactor: 
- Make stone-fruit cheap and COMMON, make null-slots SUPER easy to obtain.
- Rework shop: 
    - 2 food-shop slots
    - 3 normal shop slots
    - 1 COMMON shop-slot (only spawns COMMON items)
- Change reroll-slot to trigger on LEVEL-UP.
- Change treasure-bags: Make them spawn cloud-slots, have them FLOATY.
- Rare/Epic items can now spawn in normal shop- BUT they are extremely rare.


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
- Put `BONUS` count in UI in `lootplot.main`

## Bonus UX:
Whenever points are earned with bonus, use `lp.queue` to add bonus points.
That way, the user can SEE visually how it actually works.
And it isn't just another confusing number.
(Might need to )

### SPIKE:
(ONLY DO THIS TASK WHEN YOU ARE FEELING REFRESHED AND CREATIVE!!!)
- Create items that interact with BONUS:::
- ITEM: lose bonus, increase mult
- ITEM-2: gain bonus, decrease mult
- ITEM-3: earn 30 points, decrease bonus by 1
- ITEM-4: If bonus is more/less than X, do XYZ
- BONUS-SHIELD: If bonus is negative, make bonus positive
- (Create more BONUS items; be creative; look for SYNERGIES.)


- Create mineral shovel-items (Give +1 bonus)


- Make Star background better-  
back stars should be smaller and more transparent

- Change color of fog/clouds for different backgrounds


- Instead of saying "Round 7/6", It should say "LEVEL COMPLETE"


- Rename `lootplot.main` -> `lootplot.singleplayer`.
- Rename `lootplot.s0.content` --> `lootplot.s0`.
- Move doomclock, pulse-button, next-level-button to `lootplot.s0`
^^^ WARNING: Will require refactors to attributes. 
Perhaps we need to allow attributes to have default-values?


- Destroy all shop-slots after LEVEL-10.
This prevents the player ruining the game for themselves.
https://www.reddit.com/r/balatro/comments/1g0o0ax/wow_not_caring_about_the_endless_mode_made_the/

- Have an end to the tutorial, (and maybe an exit-button?)

- Have mult in tutorial. 
(specifically; explain that putting mult BEFORE points is good!)

- Explain target-visuals in the tutorial

- Activator-items:
- If target items dont earn any points, Pulse them
- If target items earn more than 5 points, Pulse them 
^^^ Idk if these are a good idea- we basically just want more synergy!


- Point balancing. Make the game easier; its too oppressive right now.


- For lootplot demo, instead of restricting items,
Make it so the player can only play 2 runs.

