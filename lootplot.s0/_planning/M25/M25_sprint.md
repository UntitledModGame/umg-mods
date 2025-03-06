

## MID-2025 SPRINT:


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




==========================================
ANY TASK ABOVE ^^^ THIS POINT IS COMPLETE
==========================================



- Lock starter items (except for tutorial-cat)
- Add unlocks for starter-items (win game)



- Make Destructive-archetype more viable. (Somehow?)
(Maybe make some rocks UNCOMMON...?)


- Make shape-tutorial better (split into 2 parts?)
- Part-1: Explain what shape is. Simple orange egg-item, on 2x2 slots, spawning slots on ROOK-1. Explain target-visuals:
```
"This item has a ROOK-1 shape. It will interact with stuff adjacent to it.
To view the item's shape, click on the item"
-- (item here)
"If the target is wiggling, that means that the target is valid, and the item will do its effect there!"
```
---> 
- Part-2: "playground" for more complex items 
```
"Items can have different shapes, and different purposes."
(potion, rook-glove, dragonfruit)
"Have a play around!"
```


- (SPIKE?) Make shop smaller (at least, for one-ball)
==> 2 shop-slots, 2 food-slots?


- Make a starting-item that starts with a rulebender-slot



- Make a few more `Rotate/Unlock` items that scale:
(futuristic-item sprites, top right)
- Give some LEVEL-UP items `Unlock` trigger?
- Red metal cube: On Rotate/Unlock, give +0.4 mult to slots (shape=ON)
- Blue metal cube: On Rotate/Unlock, give +3 bonus to slots (shape=ON)
- Green metal cube: On Rotate/Unlock, trigger Reroll on slots and items (shape=KING-2)
- Gold metal cube: On Rotate/Unlock, earn $5. GRUB-10.



- Rename steel-slots to "anti-bonus slots". Make them easier to get.
(They should do the exact same thing as before, except halve the current bonus)


- Make slots and items activate a bit separately:  
Michael didnt understand that the slots and items activated independently.  
Maybe we should buffer the activations of the items:  
Ie, activate slot, then activate item.  
(instead of both triggering at same time)   



- Get rid of start-game loading times
Everyone seems to get annoyed at the loading times.
Lets try remove the loading-times for worldgen as much as possible.
Also, when we trigger REROLL on items at start, lets just trigger it instantly. No need to use Bufferer.


- Create a more well-defined lose-condition:
- When a game is lost, dont allow player to "continue run"
- When a game is lost, dont allow player to recover the run through Rerolling. Lost is LOST!
- When a game is lost, tell the player: "Game over" text, similar to "You win" text?



- plan what items should be unlocked at the start of the game   
    --> rotate items should start locked  
    --> destructive-archetype should probably start locked too?  


- Add item unlock infrastructure
- Create "UNLOCKED" popup UI widget when the game is won
- Make complex items locked at the start of the game



- Add credits screen (main menu?)
{
    Artist(s)
    Coders (Auahdark, skahd, myself)
    Playtesters
    Music
    SFX
}


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


