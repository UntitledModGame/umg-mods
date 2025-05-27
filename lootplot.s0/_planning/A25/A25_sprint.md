

# After-Release 2025 sprint

## =============================
## DONE:
## =============================


- Fixed crash https://discord.com/channels/863625920991854602/1373076077047713843/1373076077047713843

- (CRASH!!) Make it so pulse/level buttons can't appear in tutorial
- (use isEntityTypeUnlocked infra)

- Fixed achievements not working

- Make golden-horseshoe a food item

- Display `INFINITY` correctly instead of nan
- Make INFINITY/NAN money work when buying/activating stuff

- Make hybrid card LEGENDARY
- Make mult card LEGENDARY

- IDEA: Reduce the number of levels for winning for EASY/NORMAL.
(Maybe easy only requires 8 levels to win...? Normal/Hard 10 levels?)

- Add SKIP button when pipeline has been running for longer than 20 seconds

- Allow pipeline to run 10 actions per tick (instead of 1)

- Automatically select a background in menu (instead of hovering locked)

- Add a button to go BACK from NewRunState -> ContinueRunState



- Rounding for reroll/pulse rings (balance: $8.348934893)
- Make golden-rings sticky


- SLOT: Guardian slot
Items on this slot cannot steal points, bonus, or multiplier.


- SLOT: Cat slot
Spawns a cat



- Rename to rainbow ball


- Change copykato -> Midas cat. Copy self to slots. Transform slots into golden-slots


- Remove "End-Early" button (its glitched with rounds)

- Make juice/sound not play multiple stuff in one tick
- Add round-speed-up code


- Use robo-streamer to put Olexas videos on steam homepage


- plan number-of-levels changes: (Easy=6, Normal=8, Hard=10)
- Ask jojo, ceroba, Obvi, etc about their opinions on this.


- Nerf the activations-cap from 40 -> 20


- Create/add steam-broadcast assets


- There should be a legendary cat:
catcat: Earns +2 points for every other cat on the board

Rings: (increase threshold to $20 from $10..?)


- Make bowling-ball income a *bit* less oppressive


- UI changes in UMG-CORE: Buttons should have a hover effect. 

- Also, ALL buttons should play a sound when pressed. (In NewRunScreen) 
(Put sfx in StretchableButton direclty?)


Balls should actually DO stuff:
G-BALL:
GRUB-20, Earns $1

6-ball: 
On Reroll, Pulse: Earn $2

5-ball:
On Rotate, Pulse: Earn $2

Blank ball:
Remove the normal-slots

Bowling ball:
Increase doom-count of slots (KING-1)
Costs $2 to activate
--> with this, the slots can start with a lower doomCount

7 ball: on activation, turns slot into slate block (ON shape)
slate block: cannot hold epic (IV) items. (or anything higher) 


- Apple pie: Randomizes shape of item


- Change cucumber: triggers Reroll on items/slots 3 times (Queen-3)

- Change cucumber-slices --> green-apple (better theming/intuition)


- Fix Reader.fail crash
https://discord.com/channels/863625920991854602/1374620418815557663/1374621220049522771


- Fix rulebender-slot showing incorrect description
https://discord.com/channels/863625920991854602/1374826401068224542/1374826401068224542
--> ^^^^ we will need to make descriptions dynamic with a function


- Adjust doomed_tool item (it was originally built for food-items)


- payment for robostreamer



- LOCKED-SLOTS ADJUSTMENTS:
- Easy mode: Remain same.
- Normal mode: Limit islands to size 1, and size 3-4
- Hard mode: Limit islands to size 1.


Prism: NERF

Round-timer: remove/nerf this item


Backwards-loan:
Sets the number of rounds per level to 7
Transforms all Reroll-buttons into glass-slots


Multiplier card:
Swaps Bonus and Multiplier 

Robbers sack:
Makes money negative.
Set item prices to 0. (ROOK-8)




Negative-shield: NERF OR REMOVE.



- Nerf compass? (its SOOO fun to use tho) (maybe reduce earnings to $0.5?)
COMPASS NERF IDEA: 
No longer sets money to 0. 
Adds $1 earned to glass-slots.
FLOATY. shape=ON.
Trigger = LEVEL-UP
(NOTE: Make sure it works on red-glass slots too! Use `lootplotTags`)


Change golden-bell to just buff the slot.
Nothing else.


- UX IMPROVEMENT:,
star and star-card should use orange-color for "shapes" word
https://www.twitch.tv/yoshekllyou/clip/BlatantAbrasiveCardNomNom-flJgHMkA6MGbadJT

- All pie-items and glove-items should use orange-color in descriptions too


ITEM: Trigger card
Swaps triggers of items (Eg Pulse, Reroll)
(shape=VERTICAL-1)


Change `isEntityTypeUnlocked = helper.unlockAfterWins(X)` to
`unlockAfterWins = 5`.
That way, we can easily introspect item-pools to see what items are available at each stage of the game.
Maybe we should even do `/spawnItems [win0|win1|win2|win3|...]`
that way, we can see rarities too


- Give `unlockAfterWins` to ALL slots.


- Make slot-spawner-item descriptions direct.
- "Spawns a golden slot" X NO NO NO.
- "Spawns a slot that multiplies points, but costs money to use"



- Make pink-slot not work on food-items



- 5-ball is too cluttered. make it simpler; remove one of the records



- Shovel items: Make them Pulse/Reroll slots, and earn a lot of points
(remove the scaling)


- SLOT: Cloth slot
On Pulse: Triggers LEVEL-UP on item





## =============================
## TODO:
## =============================




- NEW ITEM: Copper-coins. GRUB-20. Earns $2. Earns 20 points.
(STICKY, UNCOMMON)
^^^ and with this, maybe make spare-coins RARE, and stronger...?

- Create curses:
CURSE: Destroys the closest slot that earns money
CURSE: Destroy the closest item that earns money
CURSE: After X activations, destroys the 3 closest slots
CURSE: Glassbreaker: Destroys 50% of all glass slots
CURSE: Halves the number of lives on all items and slots
CURSE: Give DOOMED-5 to a random slot (not a button!)
CURSE: While this curse is alive, earn 10% less multiplier
(can be implemented via onUpdate and keeping track of the deltas)
CURSE: While this curse is alive, earn 10% less Bonus
CURSE: Destroy all items (ROOK-6)
CURSE: Subtract 10 points from items (ROOK-6)
CURSE: On Level-Up: Make random item STUCK
CURSE: Remove Pulse trigger from the closest item
CURSE: Steals $1 for every other curse on the plot
CURSE: On Level-Up: Make a random slot cost $1 to activate
CURSE: On Level-Up: transform 2 random slots into null-slots
CURSE: Removes FLOATY from the closest floating item
CURSE: When an item is purchased, steal $1


- Emerald shop-slot:
Spawns items and replaces Pulse-trigger with Reroll-trigger

- 6-ball: (Could replace shop-slots with green-shop-slots...?)



- Pink shop-slot:
Spawns items and gives them +3 lives

- Purple shop-slot:
Spawns items and gives them DOOMED-10


- JOJO FEEDBACK:
More items should have adjacency interactions.
(For example axe-items, or scythe-items)
^^^ this is what makes stuff interesting



- Create DAILY run:
- Randomize shop (Start with custom/special shop slots)
    - doomed-shop, only sells doomed-items?
    - discounted-shop, all prices 50% off
- Randomize main-island
- Randomize some initial plot items
- Randomize curses
- Random neutral starting scenarios: 
    - Tax-slot + null-slots
    - Surrounded by stone-slots
    - Scattered stone-slots that give money/points
    - Start with 1 pink-slot in the middle
    - Start with 1 rulebender-slot in the middle
    - Start with 1 guardian-slot in the middle
    - Start with destroy-slot instead of sell-slot


- Remove 4-ball starter-itme
- Remove 4-ball achievements


- New item: Interdimensional-eye: Subtracts 50 Bonus, Earns +4 mult


- Make L-Ball better and more exciting; (its really boring currently)


- Fix load save crash  https://discord.com/channels/863625920991854602/1374371590778916894/1374371590778916894



- Make knight-glove and Up-glove look a bit different
(change the fingers?)

- Contraption-items: They all look too similar

- Leather-items: Too similar...? Even the dev forgets what they do!!! Ragh!


- Number-keys shortcuts for pressing action-buttons


- Consider adding DOOMED tools? (Purple-color)


- ITEM: Trigger card
Swaps triggers of items (Eg Pulse, Reroll)
(shape=VERTICAL-1)


## Worldgen ideas:,
- Worldgen slots that buff items permanently,
- Structures to discover, 
- fortresses of stone-slots that you can break into,
- Set-piece: a little stronghold of cats
- Set-piece: a fortress with PRISM in the middle (Prism should be a UNIQUE item)
- A button that, when pressed, gives some big buff (EG: decreases round by 1)



## ADD NEW MUSIC
https://m.youtube.com/watch?v=JPCaFc17ur0&t=27s&pp=2AEbkAIB
- You were always in the right place,
- Cozy afternoon
- Fast lanes light rain
 
https://youtu.be/s8nkrxzOBR4?feature=shared  NOTABLE SONGS:
- Bullet witch


## Background ideas:,
- Twilight background: Dark black/blue with gray clouds

- Deep crimson background

- Rainbow background. Cool HSV/Oklab
 
- Loot-rain background. Items raining down, just like title screen. The items should be somewhat transparent so it doesnt distract

- Copycat-rain background: Background with copycats raining down



## =============================
## STRETCH / NEXT-SPRINT:
## =============================


- Made items that can't activate grayscale (need shader)

- CREATED NEW LEGENDARY ITEM: Chef's Knife: 
- On Level-Up: Spawns null-slots with food inside them. (KNIGHT shape)


- Different difficulties should spawn more or less curses 
(silver trophy, 1 curse per level) (gold trophy 2 curses per level)

- Create popup text saying "LEVEL {X} PASSED!"
- Play a cool sound when progressing to next level


- IDEA:
- Rare sack should have a 5% chance to spawn EPIC items
- Uncommon sack should have a 5% chance to spawn RARE items

