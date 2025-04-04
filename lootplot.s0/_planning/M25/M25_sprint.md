

## MID-2025 SPRINT:
### START-DATE: (  3/MARCH/2025  )


- ~~Nerf boomerangs~~

- ~~Fix test-spacing on LPState round-count and stuff (different per screen resolution!)~~

- ~~Fix skahd shop-lock bug (REPRO: buy -> lock -> reroll )~~

- ~~Make victory-shockwave cleaner, remove fade from it~~

- ~~Fix: "YOU WIN" text is black when space-background is active~~

- ~~Muting SFX doesnt work (...?)~~

- ~~Remove Pulse trigger from shards, make shards trigger via `onUpdate`.~~
--> ~~This also means we can simplify descriptions too!~~
--> ~~(DEFERRED) Also, play a nice animation when shards are combined (Take inspiration from CROPS!)~~

- ~~Make wildcard shards cost $8 or $9~~

- ~~Create white-background: (White background, Light blue clouds)~~

~~- Make a new type of stone-slot: "auto_stone_slot".~~
~~- Rarity should be EPIC.~~
~~- (Make the original stone-slot rarity=UNIQUE)~~
~~- Implicit stone slots *implicitly* spawn with random properties-~~
~~- +150 points~~
~~- +20 bonus~~
~~- +5 mult~~
~~- Earn $4~~
~~(^^^ or a mixture of the above?)~~

~~- Make FLOATY description better: "FLOATY: Can be placed in the air!"~~

~~- Create ginger-roots: Spawns stone-slots with 20 lives~~

~~- Give shapes to treasure-bags~~
~~- Make food-treasure-bags have a vertical shape instead~~
~~- (DEFERRED) Prevent treasure-bags being added to normal-slots (ie must be floating)~~
~~- Add description to treasure-bags, explaining that they must be placed on air~~
~~- Make cloud-slots destroy other slots diagonally (<--- balance reasons! Or else bishop/knight shape is OP)~~

~~- Fix bug with doomed description (DoomCount goes into negatives. Fix this.)~~

~~- Fix bug with activations arent shown if DOOMED is less than activations. This works great for items WITHOUT lives!~~
~~But its an issue when the item has many lives, activations isnt shown~~

~~- Add win stat in `lootplot.s0`~~
~~- Lock starter items (except for tutorial-cat)~~
~~- Add unlocks for starter-items (win game)~~


~~- Make key-bar transform after 4 activations (and increase mult?)~~
~~- Make wildcard-shards UNCOMMON~~
~~- Make helmet-items point downwards instead of UP, its better UX, and it makes more sense~~
~~- Keys should start with a randomized rotation. (maybe they should point diagonally? Or something? Same as spears)~~

~~/spawnSlots command~~

~~- Make Destructive-archetype more viable. (Somehow?)~~
~~- IDEA-1: Make some rocks UNCOMMON (ice-cube, mult-rocks?)~~
~~- ITEM: (UNCOMMON) Destroy items with Destroy trigger. Trigger Reroll on items with Reroll trigger. Cost $1 to activate~~

~~- Make shape-tutorial better (split into 2 parts?)~~

~~- (SPIKE?) Make shop smaller (at least, for one-ball) ==> 3 shop-slots, 2 food-slots?~~

~~- Make a starting-item that starts with a rulebender-slot~~

~~- Make dirt-starting item~~

~~- Make 8-ball starting item~~

~~- Fix perk-select scroll / layout~~

~~- Make perk-items ordered properly~~

~~- Make round-increment AFTER Pulse is done activating (fixes the LPState text being incorrect)~~

~~- Rework steel-slots per document: (Items gain a 2x points multiplier, item activations are capped at 3)~~

~~- Rework gold-slots: "Give items 5x point mult. Make items cost $1 extra to activate."~~
~~- If we do this, we MUST rework golden-worldgen slots!!!~~

~~- Adjust diamond-slot: Items on this slot earn 4x as much Bonus~~

~~- Nerf ruby-slots (Pulses 6 times)~~

~~- Create sapphire slots: Items on this slot gain a 2x points multiplier. ~~
~~If bonus is negative, this multiplier is increased to 5x.~~

~~- Make rainbow-ball starting item (starts with a tonne of random shit) (Name: "Gay"?)~~

~~- Get rid of start-game loading times~~

~~- Make slots and items activate a bit separately:~~
~~Michael didnt understand that slots and items activated independently~~   
~~Maybe we should buffer the activations of the items:~~   
~~Ie, activate slot, then activate item.~~    
~~(instead of both triggering at same time)~~

~~- Create a more well-defined lose-condition:~~
~~- When a game is lost, dont allow player to "continue run"~~
~~- When a game is lost, dont allow player to recover the run through Rerolling. Lost is LOST!~~
~~- When a game is lost, tell the player: "Game over" text, similar to "You win" text?~~

~~- UMGCLIENT: Make "Loading..." text sizing better (more consistent!)~~

~~- Remove abstract-background~~
~~- Add deep-purple background~~
~~- make teal-background look better (deeper color?)~~
~~- make yellow-cloud background~~


~~- Remove stupid implicit trigger-propagation from slots -> items. There are bugs:~~
~~- (BUG-1: causes a delay when we trigger `RESET` on slots!)~~
~~- (BUG-2: If we destroy a slot, then the item on the slot will ALSO receive Destroy trigger!!!)~~

~~- Make backgrounds locked (Locked behind wins?)~~
~~- Make background-select look better~~

~~- If you play the tutorial, it counts as a win. This will cause items to be unlocked.~~
~~- Instead of calling lp.winGame, we should just set a flag that unlocks the one-ball directly.~~

~~- Add 6-ball: (Gray pulse-button, Reroll build)~~

~~- ADD STEAM ACHIEVEMENTS (?)~~
~~- IDEA: Win with every starter-item? <--- makes it very possible/feasible for achievement hunters~~
~~- Define achievements in steamworks~~
~~- Define and deploy API from umg~~
~~- Set achievements from `lootplot.s0`~~

~~- ITEM:  UP-1; (random rotation)  Give items +10 points. 10% chance to destroy item~~

~~- (SPIKE?) Create an item that adds REPEATER to slots! (It's a really cool/fun idea)~~
~~- ALTERNATIVELY: We should add `repeatActivations` property to apple~~

~~- MICHAEL FEEDBACK: Reroll builds dont feel good. They just feel like Pulse builds, but kinda shit.~~
~~- Reroll items that need to be activated multiple times, eg: "When rerolled 3 times, do XYZ"~~

~~- (SPIKE?) Make a few more `Rotate/Unlock` items that scale:~~
~~(futuristic-item sprites, top right)~~
~~- Give some LEVEL-UP items `Unlock` trigger?~~
~~- Red metal cube: On Rotate/Unlock, give +0.4 mult to slots (shape=ON)~~
~~- Blue metal cube: On Rotate/Unlock, give +3 bonus to slots (shape=ON)~~
~~- Gold metal cube: On Rotate/Unlock, earn $5. GRUB-10.~~

~~- Animation when legendary spawns (try capture player attention)~~
~~- (Glow around EPIC items too to draw attention to them?)~~
~~- ^^^ ONLY WHEN IN SHOP-SLOT OR CLOUD-SLOT~~

~~- Make round-modifying items LEGENDARY~~

~~- plan what items should be unlocked at the start of the game~~
~~- Add item unlock infrastructure~~

~~- Make mystery-book call the same function as sliced-apple and purple-mushroom (extract to `helper`?)~~

~~- Add credits screen (main menu?) ~~

~~- Update physics-items in UMG-core lootplot menu~~
~~- Add copycat / chubby-cat / copykitten? remove helmet items?~~

~~- lootplot.singleplayer UI: Make it so you can change SFX/Volume while paused~~

~~Iron sword, ruby sword, etc should all subtract 1 bonus. It shouldnt scale with strength!! ~~

~~- SPIKE: PLAN / Make analytics better. What information do we want to gain?  ~~

~~- CREATE ANALYTICS:~~
~~- startNewRun~~
~~- completeLevel~~
~~- buyItem~~
~~- winGame~~

~~- ITEM ADJUSTMENT:  Diamond Chest: Make it doomed-2. Right now its OP~~

~~- LOOTPLOT BALANCING IDEA: make the game more fun for veteran players.~~
~~- Wider difficulty distribution across different starting items!~~

~~- SPELLING ERROR: "targetted" should be spelled "targeted"~~

~~- Simplify item-descriptions a bit. Put `Rarity` and `Price` on the same line.~~
~~- We need a new system/qbus for this. Maybe `getItemTags`...? Or something?~~

~~- When a sack-item doesnt have ON shape, it can be used infinitely many times. (ie via bishop glove)~~

~~- ITEM: Calculator: (STICKY) Multiplies points by -1. Has an activation button~~

~~- ITEM-REFACTOR: Give activate-actionButtons to book-items!!! (Maybe make the button "Read book"?)~~

~~- When you hover an item, and use WASD to move, the item hover stays the same.~~
~~- We can fix this by just calling onUpdate to check the hover~~

~~- Put delays between slot activation and item activation~~

~~- MAKE DESCRIPTIONS BETTER:~~
~~- Give rarity border color to description-boxes (just do it hacky- its fine!)~~
~~- Put rarity/price/shape text below name (scaled down!)~~
~~- make vertical line split gray, and make it go across the whole box~~
~~- Shrink the box such that there's no wasted space~~

~~- Re-create trailer (follow same structure as old trailer tho.)~~
~~- Ensure visual-variation!!! (different backgrounds!!!)~~

~~- Update steam screenshots (Ensure visual variation - different backgrounds)~~
~~- MAKE SURE TO SHOW ITEM SYNERGIES IN DESCRIPTIONS HERE!!! (red-flag? Or Coins-and-emerald?)~~

~~- MUSIC VOLUME: Start at 0.3~~
~~- SFX VOLUME: Start at 0.5~~

~~- ACCESSIBILITY: Add a way to exit the game from lootplot.singleplayer~~
~~- Make lootplot.singleplayer ContinueRun scene ratios better~~

~~- ACCESSIBILITY: Add a way to exit the game in umg-core lootplot menu~~

~~- Make steam-page for demo~~

~~- Demo infrastructure; (a way to tell whether the game is a demo or not.)~~

~~- (DEFERRED) Put "LOOTPLOT DEMO" text top right, ~~
~~- so people (A) can tell what the game is if viewing screenshots, and (B) understand that its a demo version~~

~~- DEMO LIMITATION: We should only let the player win 1 game. After they have won, dont let them play again.~~
~~- (This works well, because the player is most likely to want to play more right after winning.)~~


~~- Add Metta's/Ravi's BGMs to the game~~
~~- Maybe we should have 10-15 second long gaps between the songs...? Or maybe have them gradually fade in/out?~~
~~MUSICS:~~
~~https://discord.com/channels/863625920991854602/863625920991854605/1352078855351042140~~
~~https://discord.com/channels/863625920991854602/863625920991854605/1352072030190698566~~
~~https://discord.com/channels/863625920991854602/863625920991854605/1354632103580401754~~
~~(INCOMPLETE:) https://discord.com/channels/@me/1316601752098967665/1328218664687767573~~

~~- MUSIC: Adjust the volume of all tracks so it's somewhat consistent and nice~~

~~- MUSIC: Consider adding HeatlyBro's music- Dark-Alley~~



==========================================
ANY TASK ABOVE ^^^ THIS POINT IS COMPLETE
==========================================


- Add demo-infra to UMG CI-CD. (LOOTPLOT_DEMO.txt at project root)


- In descriptions, rename target-shape to `target`


- Add x64 and x86 support for linux. Currently, in `build/linux64/love.AppImage`, the appimage is x86 ONLY!
- ALSO, ANOTHER IMPORTANT NOTE: Linux doesnt work anyway!!! (0 bytes, doesnt install anything???)
- (Get Auahdark to help...?)
- We could also just put in the steam-requirements that you need an x86 compatible processor.


- Submit lootplot build


- Gather list of streamers/yters to send keys to


- RELEASE DEMO!!!



=============================================
ANY TASK BELOW (VVV) STRETCH-GOAL / AFTER DEMO
=============================================


- Make Japanese localization ?

- Make Korean localization ?



- SECRET CHALLENGE STARTER-ITEMS:
What about this for an idea:
There is a small chance for 1x1 worldgen-locked slots to contain a "meta-chest."
When the meta-chest is unlocked, you unlock a secret challenge-starting item?

^^^ this would be extremely simple to implement, it would be fun, because itd be exciting to uncover new items, and itd just be a cool thing.
Bowling-ball could be unlocked this way, for example


- ACCESSIBILITY: Add a way to pause with mouse

