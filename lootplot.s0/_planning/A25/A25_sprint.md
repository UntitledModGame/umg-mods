

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



## =============================
## TODO:
## =============================


- Make LEGENDARY items rarer in worldgen (add RARE items too)
- Add LEGENDARY-CHEST to locked-slots, instead of items directly
- Replace EPIC chest with LEGENDARY chest



- Change gift-box:
5% Chance to turn into a Legendary chest
Earns 30 points


- Allow pipeline to run 10 actions per tick (instead of 1)


- Use robo-streamer to put Olexas videos on steam homepage


- (CRASH)  https://discord.com/channels/863625920991854602/1373658843120406568


- Automatically select a background in menu (instead of hovering locked)

- Rounding for reroll/pulse rings (balance: $8.348934893)
- Make golden-rings sticky

- Number-keys shortcuts for pressing action-buttons


- UI changes in UMG-CORE: Buttons should have a hover effect. 

- Also, ALL buttons should play a sound when pressed. (In NewRunScreen) 
(Put sfx in StretchableButton direclty?)


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



- Create DAILY run



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

