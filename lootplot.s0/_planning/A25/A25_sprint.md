

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


- NEW ITEM: Copper-coins. GRUB-20. Earns $2. Earns 20 points.
(STICKY, UNCOMMON)
^^^ and with this, maybe make spare-coins RARE, and stronger...?


- ITEM: Trigger card
Swaps triggers of items (Eg Pulse, Reroll)
(shape=VERTICAL-1)


CURSE: Cursed Slab: On Pulse: 10% chance to transform random slot into a null-slot
CURSE: Cursed slot dagger: Give DOOMED-15 to a random slot (doesn't work on buttons)

CURSE: Tomb of doom: Give items DOOMED-6 (ROOK-6)
CURSE: Tomb of doom: Give slots DOOMED-10 (doesnt work on buttons) (ROOK-6)
CURSE: Tomb of points: Subtract 10 points from items (ROOK-6)
CURSE: Tomb of bonus: Subtract 2 bonus from items (ROOK-6)
CURSE: Tomb of multiplier: Subtract 0.4 mult from items (ROOK-6)
CURSE: Tomb of money: Make slots cost $0.1 extra to activate (ROOK-6)
CURSE: Tomb of sticky: Make items STICKY (ROOK-6)

CURSE: Cursed grubby coins: On Pulse, lose 10 points. GRUB-15
CURSE: Golden shivs: Destroys the closest item that earns money
CURSE: Golden blocks: Destroys the closest slot that earns money
CURSE: Bankers helmet: On Pulse: Make a random item cost $0.2 to activate

CURSE: Cursed coin: Steals $0.5 for every other curse 
CURSE: Injunction: Remove Pulse trigger from the closest item (DOOMED-10)
CURSE: Heart leech: Removes 4 lives from ALL items and slots
CURSE: Bubbling goo: On Pulse: Make a random food-item STUCK
CURSE: Glass-shard: Destroys 30% of ALL glass slots
CURSE: Cursed life potion: Give a random curse +2 lives
CURSE: Broken shield: On Pulse: Trigger pulse on other curse items (KING-3)


CURSE: Orca: On Pulse: Destroys a random FLOATY item.
CURSE: Skeleton-cat: On Pulse: 10% chance to clone itself. Steal 50 points (KNIGHT)

- Make it so slot-spawner items cant spawn slots below curses.
That'd be OP; we would be able to clear curses too easily.


SPIKE: Figure out how curse-spawning will work.
(See `lp_curses_mod.md`)

CURSE: Medusa: On Pulse: Transforms a random empty-slot into stone
CURSE: Leprechaun: If money is greater than $200, spawn a curse

CURSE: Stone-hand: After X activations, spawn Y new curses (CAN BE CONFIGURED)
(^^^^ this guy should spawn at the start of most runs)

CURSE: Trophy Guardian: On the final level, spawn 3 random curses.
(^^^ this guy too)
(we should avoid spawning TOO many curses at start, avoid overwhelm player.)


- Emerald shop-slot:
Spawns items and replaces Pulse-trigger with Reroll-trigger


- Pink shop-slot:
Spawns items and gives them +3 lives


- Purple shop-slot:
Spawns items and gives them DOOMED-10



INJUNCTION curses: Tonnes of run-variance!!! (use contract-curse for this)
the player can START with these curses
- Null-slots get turned to stone
- Glass-slots get turned to stone
- Slots that earn bonus or points get turned to stone
- All items with Repeater get transformed into manure
- All items with Grubby get transformed into manure
- All items that earn bonus get transformed into manure
- All items that subtract bonus get transformed into manure
- All items that earn money get transformed into manure
- All items with Destroy trigger get transformed into manure
- All items with Rotate trigger get transformed into manure
- Subtract -1 activations from ALL items (cannot go below 1)
- All items with a modified {col}shape{/col} get transformed into manure
- All items with modified {col}triggers{/col} get transformed into manure



- Create DAILY run: 
- Randomize shop (Start with custom/special shop slots)
    - discounted-shop, all prices 50% off
    - pink-shop-slot, green-shop-slot
    - doomed-shop-slot, only sells doomed-items?
    - start with pineapple-ring? Negotiator? Balloon?
- Randomize main-island
- Randomize some initial plot items
    - Remember to give them random attributes!!!
    - FLOATY, DOOMED-10, GRUBBY, STICKY, REPEATER
- Randomize curses
    - (Some curses should start DOOMED-10)
- Random neutral starting scenarios: 
    - Tax-slot + null-slots
    - Surrounded by stone-slots
    - Scattered stone-slots that give money/points
    - Start with 1 pink-slot in the middle
    - Start with a cat-slot
    - Start with rotate-slot, surrounded by a big island
    - Start with a gravel-island
    - Start with 1 rulebender-slot in the middle
    - Start with 1 guardian-slot in the middle
    - Start with destroy-slot instead of sell-slot


NORMAL-MODE:
- Stonehand: spawns 3 curses after 25 activations


HARD-MODE:
- Spawns a trophy-guardian, and 2 stone-hands (on ALL levels)
- (Stone-hand-1 should spawn 2 curses, after 15 activations)
- (Stone-hand-2 should spawn 3 curses, after 25 activations)


Add curses to DAILY-RUN


Difficulty Unlocks:
After 2 wins, medium is unlocked for ALL balls.
After 4 wins, hard is unlocked for ALL balls.


- Make it so starting-items are unlocked FASTER. 
(after defeating S-ball, ALL starter-items should be unlocked.)
(Players dont wanna grind, man.)



- UPDATE LOVE2D! It's currently not working on some vulkan machines



- Remove 4-ball starter-item
- Remove 4-ball achievements


STARTER-ITEM UNIQUENESS:
Every advanced starter-item should "FEEL" unique.
(Kinda like how the 8-ball "feels" unique)

- Make L-Ball better and more exciting; (its really boring currently)
(Maybe a hybrid lives/price archetype...?)
(Also maybe it should spawn with a special INJUNCTION curse)


- We (probably) need a better way to tell the player what curses are.
Maybe an item that transforms into a random curse when placed?
IDEA: 
Cursed Cheese: cost $0, RARE, unlockAfterWins=1, 
    spawns a curse
    earns $10





## =============================
## TODO:
## =============================


- Fix load save crash  https://discord.com/channels/863625920991854602/1374371590778916894/1374371590778916894



## ADD NEW MUSIC
https://m.youtube.com/watch?v=JPCaFc17ur0&t=27s&pp=2AEbkAIB
- ~~You were always in the right place,~~
- Cozy afternoon
- Fast lanes light rain
 
https://youtu.be/s8nkrxzOBR4?feature=shared  NOTABLE SONGS:
~~- Bullet witch~~ (meh, maybe not, too upbeat)

https://backgroundsounds.itch.io/fun-music-loops
(PREVIEW: https://soundcloud.com/bgs_stockaudio/fun-music-loops)
- 1:43 onwards
- 8:14 onwards (menu music?)
- 5:11 onwards (MENU MUSIC!!??)


## =============================
## STRETCH / NEXT-SPRINT:
## =============================


- Number-keys shortcuts for pressing action-buttons


- Consider adding DOOMED tools? (Purple-color)


- JOJO FEEDBACK:
More items should have adjacency interactions.
(For example axe-items, or scythe-items)
^^^ this is what makes stuff interesting



## Background ideas:,
- Twilight background: Dark black/blue with gray clouds

- Rainbow background. Cool HSV/Oklab
 
- Loot-rain background. Items raining down, just like title screen. The items should be somewhat transparent so it doesnt distract

- Copycat-rain background: Background with copycats raining down






## Worldgen ideas:,
- Worldgen slots that buff items permanently,
- Structures to discover, 
- fortresses of stone-slots that you can break into,
- Set-piece: a little stronghold of cats
- Set-piece: a fortress with PRISM in the middle (Prism should be a UNIQUE item)
- A button that, when pressed, gives some big buff (EG: decreases round by 1)



- Made items that can't activate grayscale (need shader)

- CREATED NEW LEGENDARY ITEM: Chef's Knife: 
- On Level-Up: Spawns null-slots with food inside them. (KNIGHT shape)


- Different difficulties should spawn more or less curses 
(silver trophy, 1 curse per level) (gold trophy 2 curses per level)

- Create popup text saying "LEVEL {X} PASSED!"
- Play a cool sound when progressing to next level


- New item: Interdimensional-eye: Subtracts 50 Bonus, Earns +4 mult


- IDEA:
- Rare sack should have a 5% chance to spawn EPIC items
- Uncommon sack should have a 5% chance to spawn RARE items


DO THESE LATER: (They need to be spawned in a special position to work)
CURSE: Cursed purple balloon: On Buy, 30% chance to make purchased item DOOMED-5
CURSE: Cursed purple balloon: On Buy, 30% chance to make purchased item DOOMED-5
CURSE: Goblin glasses: When an item is purchased, steal $1 (QUEEN-3)
CURSE: Mushroom-wizard: 50% chance to spawn a Tentacle on a random empty-slot
CURSE: Tentacle: -50 points
CURSE: Cube slime: On Pulse: 30% chance to make a random item STUCK

