

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



==========================================
ANY TASK ABOVE ^^^ THIS POINT IS COMPLETE
==========================================


- plan what items should be unlocked at the start of the game   
    --> rotate items should start locked  
    --> destructive-archetype should probably start locked too?  
- IMPORTANT: PLAN AN API FOR UNLOCKING ITEMS!!!
- (Complex items should be locked for the demo too! Ideally we should use the same API for this)

- Add item unlock infrastructure
- NO NEED TO ADD AN "UNLOCKED" POPUP- IMO, too complicated. Just unlock items without any indicator, its "fine"


- Add Metta's/Ravi's BGMs to the game
- Maybe we should have 10-15 second long gaps between the songs...? Or maybe have them gradually fade in/out?
MUSICS:
https://discord.com/channels/863625920991854602/863625920991854605/1352078855351042140
https://discord.com/channels/863625920991854602/863625920991854605/1352072030190698566
(INCOMPLETE:) https://discord.com/channels/@me/1316601752098967665/1328218664687767573
(INCOMPLETE:) https://discord.com/channels/@me/1316601752098967665/1351329652500856862


- Make mystery-book call the same function as sliced-apple and purple-mushroom (extract to `helper`?)


- Add credits screen (main menu?)
{
    Artist(s)
    Coders (Auahdark, skahd, myself)
    Playtesters
    Music
    SFX
}


- lootplot.singleplayer UI: Make it so you can change SFX/Volume while paused


- SPIKE: Make analytics better.
MAKE SURE ITS DEFINITELY RUNNING PROPERLY BEFORE THE DEMO!!!  
Do really good planning.  
What sort of information do we want to gain from analytics?  
Apply 80/20 rule.  
- What insights are easy to gather, but have high impact?  
- What will be the most impactful in terms of player-retention?
---> Remember, we really need to focus on the players that "drop out" early;
ie, the players that play for 20 minutes, and then quit/refund.  
What makes them stop playing?  


- Limit number of rounds to 30 for the demo...?


- Gather list of streamers/yters to send keys to


- RELEASE DEMO!!!



=============================================
ANY TASK BELOW (VVV) STRETCH-GOAL / AFTER DEMO
=============================================


- SECRET CHALLENGE STARTER-ITEMS:
What about this for an idea:
There is a small chance for 1x1 worldgen-locked slots to contain a "meta-chest."
When the meta-chest is unlocked, you unlock a secret challenge-starting item?

^^^ this would be extremely simple to implement, it would be fun, because itd be exciting to uncover new items, and itd just be a cool thing.
Bowling-ball could be unlocked this way, for example

