

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


## =============================
## TODO:
## =============================



- There should be a legendary cat:
catcat: Earns +2 points for every other cat on the board

Rings: (increase threshold to $20 from $10..?)


- Make bowling-ball income a *bit* less oppressive


- Change cucumber: triggers Reroll on items/slots 3 times (Queen-3)

- Change cucumber-slices --> green-apple (better theming/intuition)


- UI changes in UMG-CORE: Buttons should have a hover effect. 

- Also, ALL buttons should play a sound when pressed. (In NewRunScreen) 
(Put sfx in StretchableButton direclty?)


- Apple pie: Randomizes shape of item


- payment for robostreamer


- Nerf prism, backwards-loan, and ESPECIALLY round-timer
- Nerf compass? (its SOOO fun to use tho) (maybe reduce earnings to $0.5?)

- Add golden-trout item (Steals $15, makes slots earn $1)

- SLOT: Cloth slot
On Pulse: Triggers LEVEL-UP on item


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
CURSE: On Level-Up: Make a random item STUCK
CURSE: Remove Pulse trigger from the closest item
CURSE: Steals $1 for every other curse on the plot
CURSE: On Level-Up: Make a random slot cost $1 to activate
CURSE: On Level-Up: transform 2 random slots into null-slots
CURSE: Removes FLOATY from the closest floating item
CURSE: When an item is purchased, steal $1



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



- Create DAILY run:
- Randomize shop
- Randomize main-island
- Randomlize starting-items
- Randomize curses


- Remove 4-ball



- Make knight-glove and Up-glove look a bit different
(change the fingers?)

- Contraption-items: They all look too similar

- Leather-items: Too similar...?


- Number-keys shortcuts for pressing action-buttons






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

