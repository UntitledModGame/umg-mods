


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


- (((DONE))) Create mineral shovel-items (Give +1 bonus)


- (((DONE))) Make Star background better-  
back stars should be smaller and more transparent


- (((DONE))) Change color of fog/clouds for different backgrounds


- (((DONE))) Add cherry-background (Cloud-background, but pink)
- (((DONE))) Add sunset-background (Cloud-background, but orange)


- (((DONE))) Added Copper tools - activate on ROTATE


- (((DONE))) Add animation/particles when fog is cleared (test w/ map)


- (((DONE))) Make background select UI much nicer:
- (((DONE))) Make proper cards for it
- (((DONE))) Touch up the icons
- (((DONE))) Touch up the arrow-buttons


- (((DONE))) Instead of saying "Round 7/6", It should say "LEVEL COMPLETE"


- (((DONE))) ITEM: Lone-sword:
Shape: Rook-5
Give +3 mult
Destroy all items. Give +X bonus

- (((DONE))) ITEM:
Earn $2
GRUB-10

- (((DONE-variation))) ITEM: 
If money is less than $10, permanenly gain +8 points
Earns 8 points

- (((DONE-variation))) ITEM: Tumbling cat:
Same as copycat, but UP-3
Rotates when activated

- (((DONE-variation))) ITEM: Trigger = REROLL,PULSE
Permanently Gain +5 points when REROLLed.
Earns 5 points

- (((DONE))) ITEM: golden knife
Destroy target items.
Earn $1 for each
(shape: UP-1)

- (((DONE))) ITEM: Red flag:
If mult is below 1, add 4 mult


- (((DONE))) Gear: make it an RARE/EPIC item

- (((DONE))) Records work with REROLL trigger, as well as ROTATE trigger


- (((DONE))) Rename `lootplot.main` -> `lootplot.singleplayer`.
- (((DONE))) Move `lootplot.s0.starting_items` --> `lootplot.s0`.
- (((DONE))) Rename `lootplot.s0.content` --> `lootplot.s0`.
- (((DONE))) Move doomclock, pulse-button, next-level-button to `lootplot.s0`
- (((DONE))) Move tutorial to `lootplot.s0`
^^^ WARNING: Will require refactors to attributes. 
Perhaps we need to allow attributes to have default-values?


- (((DONE))) RESET items BEFORE Pulsing the plot. This ensures that REROLL archetype doesn't avoid activations.
ALSO: We will need to refactor how the round-increment works.
Currently, the round-increment works by listening to RESET trigger. But this will cause rounds to be incremented twice, which is nasty.
Fix this!


- (((DONE))) Remove golden-cap. It's poorly designed. Remove other caps too...?


- (((DONE))) Change hammer items --> scythe items
- (((DONE))) Create NEW hammer items --> Earn points, lose BONUS

- (((DONE))) Create bonus archetype folders



- (((DONE))) Make negative-bonus display correctly.
Currently, it displays like:  `(+-2 bonus)`.
Maybe change color to red too...?


(((DONE))) Make BONUS more intuitive:  
- (((DONE))) Seperate `pointsGenerated` callbacks into bonusPointsGenerated and normalPointsGenerated
- (((DONE))) Text popup should be same color as BONUS_COLOR
- (((DONE))) Sound should play when bonus points are generated

- (((DONE))) Sound + popups for when `mult` increases/decreases

- (((DONE))) Sound + popups for when `bonus` increases/decreases


- (((DONE))) Have mult in tutorial. 
(specifically; explain that putting mult BEFORE points is good!)

- (((DONE))) Have BONUS in tutorial.
(specifically; explain that putting bonus BEFORE points is good!)

- (((DONE))) Explain target-visuals in the tutorial

- (((DONE))) Make custom pulse-button in tutorial.
    - (((DONE))) Pulse-button shouldn't generate money
    - (((DONE))) Points, mult, bonus should ALL be reset at the end of every round
    - (((DONE))) Description should be better

- (((DONE))) Have an end to the tutorial, (and maybe an exit-button?)



- (((DONE))) Create diagonal-shapes

- (((DONE))) Make spears activate items


- (((DONE))) SHOVEL-ITEM CHANGES:
if item has DESTROY trigger, destroy item


- (((DONE))) Doomed-loaf:
Spawn a food-shop-slot (shape=ON)


- (((DONE))) Replace bonus-points sound with this one:
A: https://freesound.org/people/Mafon2/sounds/371878/  
B: https://freesound.org/people/rhodesmas/sounds/342759/?  
I think I prefer A tho.

- (((DONE))) ITEM:
multiplies mult by -1.5


- (((DONE))) ITEM: Fortune cookie
Randomizes items, preserving rarity.
(Doesn't work on UNIQUE items)


- (((DONE))) Orange die:
On Reroll:
Rotate items
Trigger PULSE on items
(archetype broadening)


- (((DONE))) Mushroom refactors idea:
- (((DONE))) Red mush: Give BONUS to slot 
- (((DONE))) Blue mush: Give MULT to slot
- (((DONE))) Green mush: Give POINTS to slot
- (((DONE))) Purple mush: Randomize slots
KING-shape?
The reason this would work well, IMO, is because it would make the plot more interesting.
Instead of just having slots with no properties, suddenly, slots have mult! Slots have Bonus! Its all very interesting 


- (((DONE))) Bonus visual for slots


- (((DONE))) SLOT:
rulebender slot: Item's properties are multiplied by -1
(points, bonus, mult, moneyGenerated)


- (((DONE))) ITEM:
Bonus brick:
Give +20 bonus
Lose 2 bonus permanently when activated


- (((DONE))) ITEM: Voidbox
Cost $3 to activate
Add +1 doomed to doomed-items


(((DONE))) Scaling items:
{
    - (((DONE))) ITEM:
    On LEVEL-UP, UNLOCK:  Add +1 bonus to items/slots (ROOK-3)
    - (((DONE))) ITEM:
    On LEVEL-UP, UNLOCK:  Add +0.2 mult to items/slots (ROOK-3)
    - (((DONE))) ITEM:
    On LEVEL-UP, UNLOCK:  Add +10 points to items/slots (ROOK-3)
}

- (((DONE))) ITEM: Salmon steak:
Trigger BUY, LEVEL-UP, ROTATE, and REROLL on targetted items.


- (((DONE))) ITEM: Boomerang (UNCOMMON)
Earn 2 points 6 times

- (((DONE))) ITEM: Bowl (UNCOMMON)
On Pulse, Reroll:
Rotates itself, and earns +2 bonus

- (((DONE))) ITEM: Violin
Pulses items. Cost $1 to activate

- (((DONE))) ITEM: Deathly helmet 
When a target item is destroyed, give items +10 points

- (((DONE))) ITEM CLASS: Chestplates!!! (Shape: HORIZONTAL-3)
- (((DONE))) Deathly chestplate: When an item is destroyed, give items +20 points and -1 bonus
- (((DONE))) Golden chestplate: Cost $3 to activate. Earn $1 for every target item
- (((DONE))) Copper chestplate: Cost $1 to activate. Increase price of items by $3. Rotate items.
- (((DONE))) Iron chestplate: Cost $1 to activate. Give +1 bonus to items.
- (((DONE))) Magical chestplate: Cost $2 to activate. Buff item points by the current bonus
- (((DONE))) Ethereal chestplate: Cost $1 to activate. If item has negative-bonus, give item +1 mult


- (((DONE))) ITEM REFACTOR: Anvil.
On Pulse:
Give items +2 activations, and -1 bonus permanently
shape: Union(NorthEast(1), NorthWest(1)) 


- (((DONE))) ITEM REFACTOR: Clover
On Reroll: Give items/slots +1 points permanently
(shape: BISHOP-1)


- (((DONE))) ITEM: Grass (RARE)
On Reroll: Give items +1 activations, and increase item prices by $2
DOOMED-10
(shape: UP-2)


- (((DONE))) UX CHANGE:
When purchasing off a cloud-slot, transform into a null-slot


- (((DONE))) ITEM: spawns null-slots with random food-items on top


- (((DONE))) ITEM: spawns null-slots that steal 10 points
(price = $0) 


- (((DONE))) ITEM: Emerald bar
Activates On Reroll:
After 10 activations, spawns a Reroll button-slot


- (((DONE))) Convert white-die to golden die.
- (((DONE))) Then, White Die: On Reroll, trigger Reroll on items. (CIRCLE-2 shape)


- (((DONE))) Add random-rotations to items (spear-items, crossbows, shovel-items.)
This makes the game just a bit more interesting.


- (((DONE))) ITEM- Crimson leather:
Subtract 4 mult.
Give +0.5 mult to items with Destroy trigger.

- (((DONE))) ITEM- Teal leather:
Subtract 25 bonus
Give +5 bonus to items with Destroy trigger.



- (((DONE))) ITEM: Fish skeleton:
Spawn free UNCOMMON items on dirt-slots.
Give +3 bonus.


- (((DONE))) ITEM ADJUSTMENT: Spanner:
Make it earn +2 mult, as well as rotate items.
This makes it more broad, and more useful


- (((DONE))) ITEM:
On Pulse:
Give +2 bonus and +0.1 mult to dirt slots.
Set money to $8. (<--- archetype broadening)


- (((DONE))) ITEM: Prism
Increase points requirement by 50%
Decrease round count by 1


- (((DONE))) ITEM ADJUSTMENT- Gloves:
Gloves should earn points too.
Also, they should trigger on Reroll perhaps...?


- (((DONE))) FOOD: Green Squash (DOOMED-1):
Give slots Reroll trigger.
Set money to $13.
(useful when low on money. Useful for reroll-archetype too) 


- (((DONE))) ITEM: Furnace (UP-2)
On Reroll, Pulse:
Convert items into clone-rocks.
For every item that was converted, earn $1


- (((DONE))) ITEM:  Green ticket
When an item is purchased, trigger Pulse on target slots.
(shape: KING-2)
(sticky)


- (((DONE))) BALANCING: Buff 2-cent-ticket.
A big issue with grubby-archetype is that you can't really afford expensive items.
Make this less of an issue.
Either we can increase the Grub money cap, OR, we can add grubby-infrastructure to allow purchasing of expensive items.


- (((DEFERRED))) ITEM: Green necklace (sticky)
When rerolled, earn $1
When Pulsed, lose $1

- (((DEFERRED))) ITEM: Blue necklace (sticky)
When Pulsed, earn $1
When Rerolled, lose $1


- (((DONE))) New Mineral Class:
Grubby-tools: Same as iron-tools, but grubby.

- (((DONE))) New Mineral tool: GreatSword (EPIC)
Earns points.
Comes with a 3x points multiplier


- (((DONE))) ITEM: Magic wand:
(shape: NorthEast-1)
Transform items into a clone of an existing item on the plot.


- (((DONE))) Make the game easier; Add an extra $2 or $3 per turn.
(The game is honestly just, more *fun* when you have more money.)


- (((DONE))) ITEM: Black olive
Give Destroy trigger and Rotate trigger to items
(^^^ Note: this synergizes EXTREMELY WELL with clone-rocks; since you can duplicate any item you want!)


- (((DONE))) ITEM: snake-oil
Randomize item prices between $0 and $15

- (((DONE))) ITEM: pink-mushroom
Give +6 lives to slots and trigger Pulse on slots.

- (((DONE))) Make listen-system work for slots.

- (((DONE))) ITEM: Monocle
When a slot is destroyed, earn $3 and earn +200 points

- (((DONE))) ITEM: Velvet cake: Add +0.1 mult to items/slots
- (((DONE))) ITEM: Blue cake: Add +1 bonus to items/slots

- (((DONE))) ITEM: Demon knife: (like moon-knife)
Subtract -2 mult
Subtracts -8 bonus
Gain +0.1 mult permanently

- (((DONE))) ITEM: Ghost knife: (like moon-knife)
Subtract -8 bonus
Gain +0.4 bonus permanently


- (((DONE))) ITEM: Basilisks eye
Set rarity of items to UNCOMMON
Earn 20 points

- (((DONE))) ITEM REFACTOR: Make key-bar COMMON, make it generate +0.2 mult


- (((DONE))) ITEM: Ocarina (ROOK-1)
Reduce Bonus of items by 1.
Increase points of item by 15.
(Cost $1 to activate)


- (((DONE))) ITEM REFACTOR: Make bomb activate on action-button. Make it earn $2 per slot destroyed.
Remove DOOMED from it! Bomb shouldn't be doomed.


- (((DONE))) ITEM REFACTOR: Price-card
Decrease the price of items below by $4
Increase the price of items above by $4
(shape: VERTICAL-4)


- (((DONE))) ITEM: Wooden-Television: (UNCOMMON)
Trigger PULSE on RARE items
(shape: KING-2)


- (((DONE))) ITEM: Leather boots
Trigger Pulse on slots


- (((DONE))) Interest-slot art overhaul
Currently the interest-slot looks bad.
Make it look more like the level-up button. Thx.


- (((DONE))) ITEM: Toolbelt
Spawn random items, and give them GRUB-10.
Cost $6 to activate
(GRUB-10)
(shape = HORIZONTAL-1)
(NOTE: items that are spawned will be RARE or EPIC. They cannot be doomed) 


- (((DONE))) ITEM: Champion belt
Removes GRUBBY from items.
Then, destroys items.


- (((DONE))) ANTI BONUS ITEMS - 1:
- (((DONE))) Gives +1.5 mult
(Only works if bonus is negative!)
- (((DONE))) Earns 100 points
(Only works if bonus is negative!)


- (((DONE))) Rotate-archetype also needs some love.
- (((DONE))) Add copper-sword back.
- (((DONE))) Add copper-greatsword
- (((DONE))) Add copper-hammer
- (((DONE))) Maybe add a new item: Copper-Bar...?


- (((DONE))) Slot: Destroy slot (skull-logo?)
On Pulse,
Destroys item 3 times.
Earns 40 points each time. 


- (((DONE))) ITEM: Points shield
If points are negative, make points positive


- (((DONE))) Create better infra for viewing items.
Instead of just having `/spawnAllItems`, we should have:
- (((DONE))) /spawnItems all
- (((DONE))) /spawnItems clear
- (((DONE))) /spawnItems grubby
- (((DONE))) /spawnItems reroll
- (((DONE))) /spawnItems rotate
- (((DONE))) /spawnItems levelup
- (((DONE))) /spawnItems unlock
- (((DONE))) /spawnItems repeater
- (((DONE))) /spawnItems listen
- (((DONE))) /spawnItems money
- (((DONE))) /spawnItems doomed
- (((DONE))) /spawnItems shape  (items with a shape)


- (((DONE))) ANTI-BONUS ITEMS - 2:
Instead of always doing: "Subtracts X bonus",
Do something like: "Divides bonus by 2".
^^^ this is nice, since it works bad with +ve bonus, but GOOD for negative-bonus.


- (((DONE))) Create rock items


- (((DONE))) Random-ppos choosing API:
- (((DONE))) Choose a random slot on the plot
    --> (buttonSlots excluded?)
- (((DONE))) Choose a random slot on the plot without an item
- (((DONE))) Choose a random empty-space on the plot
    --> (additional contraint: Must be within X spaces of slots)
    --> eg distance=1 means that its NEXT to slots


- (((DONE))) Get rid of dark-egg, it's bad and dumb. Replace with something better please-
IDEA:
- (((DONE))) "Spawn 3 null-slots. Spawn a STUCK key somewhere random on the plot"


- (((DONE))) ITEM: Paperclip
If there are no other types of this slot on the plot, spawn a copy of this slot somewhere random


- (((DONE))) ITEM: Ball of yarn
(shape: King-1)
If targetting two items of the same type, give the items +10 points permanently.
(^^^^ synergizes with copycat builds!)


- (((DONE))) Refactor `lives` system, make it so that it doesn't spawn a new entity.
We should just prevent the `:delete()` operation from occuring
--->
LITMUS TEST:
- ((PASSED)) Does REPEATER component work on rock items?
- ((PASSED)) Does DOOMED cause the item to activate many times?


- (((DONE))) Activations-cap:  
Limit activations to 50 in base lootplot.  
Perhaps have `lp.MAX_ACTIVATIONS_CAP = 50`  
(so modders can change ^^^^ as they wish)


- (((DONE))) Slot-visuals in tutorial;
Showcase DOOMED-slots, mult-slots, point-slots, bonus-slots, glass-slot, dirt-slot, etc etc
Then show one slot with ALL combined.

- (((DONE))) Back-button in tutorial
We want to be able to go backwards to previous stages



- (((DONE))) Sell slots:
Instead of 
"selling for half price, then destroy"
Sell-slots should:
"Reduce item price by half, earn money equal to price of item, then destroy"


- (((DONE))) Dirt-slot visuals:
When we scale a dirt-slot for variation, it also affects the slot-visuals.
Fix this!
Honestly it's probably best to just create sprites that have been manually flipped in Aseprite.


- (((DONE))) Glass slot QOL changes:
Make it so glass slots dont die when they have a doomed item inside.
Its frustrating.


- (((DONE))) When quitting game:
Put a screen that says "QUITTING".
Currently, the game appears to freeze when you click exit.
I dont think there is a way to fix this directly, so instead we should just make the screen brown, and put "QUITTING..." text in the middle of the screen


- Fix Listener items on Null-slots still activating!
Listener-items still activate when in a null-slot/shop-slot.
This is confusing at best, bugged at worst.
(fix this. Fix for shop-slots too!)
(IMPORTANT:: Make sure that the `BUY` trigger still works for shop-items when purchased!!!)
--
SIMPLE IDEA: Just have a slot-component: `isItemListenBlocked = true`
^^^ its very direct, very simple.


- ITEM: Uranium rocks
(shape: ROOK-1)
If item has Reroll trigger, transform into it



- Rework listen-item descriptions
We shouldn't have descriptions be implicit; they should be explicit.
(Maybe we should have a `triggerDescription` component...?)




- ITEM:
Spawns a DOOMED-4 LEGENDARY item
(oli note: Don't pick legendary-items that are already DOOMED.)



- Destroy all shop-slots after LEVEL-10.
This prevents the player ruining the game for themselves.
https://www.reddit.com/r/balatro/comments/1g0o0ax/wow_not_caring_about_the_endless_mode_made_the/


- Juice/Feedback when the point requirement is breached!!!!
If the player goes above the point quota, we should play a satisfying sound,
play a cool animation, and just make it JUICY and satisfying.
(Idk what to do, just make it SATISFYING! :D)


- Erik Idea:
Chest items spawn near your plot and if you don't get a slot under them in a couple rounds, they disappear.
The way we would implement them in practice is to make the chests STICKY, and put them on a DOOMED-4 slot or something
^^^^ Make it part of the worldgen even?
--------->
OLI FINALIZED:
Islands that are 3 or bigger: Spawn golden slots.
Islands that are exactly 1 in size: Spawns a sticky-chest item (on a null slot) 


Match3 shards:
When matched, a little sprite should pop up above them, just like when a shape is matched in CROPS!


## SPIKE: SIMPLE Anti-archetype items:
- "If there are no REPEATER items on the plot, do XYZ"
- "If there are no items with `Reroll` trigger on the plot, do XYZ"
- "If there are no items with `Destroy` trigger on the plot, do XYZ"
--->
Or, even simpler:
- "Do XYZ. Destroy all items with Reroll trigger. (shape: KING-2)"  (anti-Reroll)
- "Do XYZ. Destroy all REPEATER items. (shape: KING-2)"  (anti-REPEATER)
- "Do XYZ. Item lives are limited to 3. (shape: KING-2)"   (anti-destroy)



- Change one-ball tutorial-text:
Instead of appearing on top of slots, we should spawn a button


- Activations:
Currently, there are many income-items that have 1/1 activations.
I think we should change this! Give them 2/2 or 3/3 activations instead. It makes it more fun. Doesnt matter too much that its OP.
(Maybe nerf one-ball to $1, but give it 3 activations?)


- Proc gen food items:
Some food items should have a chance (say, 15%?) to spawn with doomCount=3, baseMoneyGenerated=-8 or something.   
(What if the baseMoneyGenerated is equal to the original basePrice of the item...?)
That way, the food item can be stored and reused.  Its a cool feature that adds variation.  
=======>
LIKEWISE: What if we had a 10% chance to spawn food-items with 1 extra life, but they were 70% more expensive? 


## (SPIKE) REALLY INTERESTING IDEA:
Consider more *SLOTS* that have exotic triggers.
For example, slots that have LEVEL-UP trigger, or DESTROY trigger.



## (SPIKE)
### Create pro-bonus items:
(ONLY DO THIS TASK WHEN YOU ARE FEELING REFRESHED AND CREATIVE!!!)
- ITEM: lose bonus, increase mult
- ITEM-2: gain bonus, decrease mult
- ITEM-3: earn 30 points, decrease bonus by 1
- ITEM-4: If bonus is more/less than X, do XYZ
- BONUS-SHIELD: If bonus is negative, make bonus positive
- (Create more BONUS items; be creative; look for SYNERGIES.)
- Do something with feather-item (was removed due to mana changes)
**IMPORTANT!!! Remember SYNERGIES!!! Try to make it emergent**
========>  
## Create anti-bonus items
EG: Item: lose -5 bonus. Gain +1 mult.
Items that generate LARGE amounts of points, but reduce BONUS.
Or, items that add mult, but reduce BONUS.
**IMPORTANT!!! Remember SYNERGIES!!! Try to make it emergent**


## (SPIKE)
### More items that cost *money* to use.
We want money to be very much a finite-resource. Spreading the player thin!





## (SPIKE)  DESTRUCTIVE ARCHETYPE!
(REMEMBER: We want maximum synergies and strategy!!! Try to weave destructive archetype into other archetypes. It SHOULDN'T be standalone.)
(NOTE:: it's **OKAY** if stuff is OP. We want to maximise FUN. Not balance.)
--->>
NOTES/PLANNING:
I think destructive-archetype will be best if we focus on the items WITH the `Destroy` triggers.
- Items that clone `Destroy` items
- Items that modify triggers (IE: gives PULSE trigger to a rock-item)


## (SPIKE)
- Make ROTATE archetype more "global". Currently it's a bit... standalone.
Add a bunch more items that rotate stuff, BUT ALSO do other stuff.
(EG: generates points, AND rotates target items)
(REMEMBER: ITS **OKAY** IF STUFF IS OP. We actually *WANT* stuff to be OP.)


- Point balancing. Make the game easier; its too oppressive right now.
- Balance the game for noobs. **DONT** BALANCE FOR PROS!!!


- For lootplot demo, instead of restricting items,
Make it so the player can only play 2 runs.


- Unlockable starting-items.
Tutorial item should be available first. Then, one-ball.



- Starting-Item idea:
How about we have a starting-item that doesn't have a Pulse button...?
Instead, we just have a "special" reroll button that activates the doomClock.
Then, we start with an extra item that gives `Reroll` trigger to items.



- Add unlocks to regular items
### SPIKE:
How are we actually going to do this sensibly?



- AGGREGATE display of points above each item:
So, say an iron-sword earns 20 points 6 times in a round. 
There should be blue text above it, that says "120".
(Same for mult.)
(^^^ TODO: not sure if this is a good idea. Might cause visual bloat and confusion...?)
(For now, lets abandon this task.)


## (SPIKE: PLANNING)
### PASSIVE ITEMS:
Why don't we have passive items?
IE: items that don't activate directly, but use `onUpdate` to have an effect.


- ITEM: panic button:
Randomizes ALL items, preserving rarity.
(Doesn't work on UNIQUE items)


