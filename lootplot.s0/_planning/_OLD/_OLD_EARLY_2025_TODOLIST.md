

## EARLY 2025 TODO-LIST
------------
Stuff to do/implement our beta-test.


## 10/JAN/2025 PARETO-PLANNING:
We need to get beta-release out ASAP.


------------


- (((DONE))) Rework iron shards (cloud-slot)


- (((DONE))) Make strong-shop-slots trigger on LEVEL-UP


- (((DONE))) Make cloud-slots trigger BUY properly! (To work with balloons, etc)


- (((DONE))) Write blog-post detailing 2024 learning recap
- (((DONE))) Write document detailing what future-UMG would look like


- (((DONE))) Create coal shards
same as iron-shards, but NOT floating! Gives mult instead of points


- (((DONE))) Rework food shards


- (((DONE))) Put a juicy click and animation visual when clicking button-slots
    (The serverside-delay makes it feel unresponsive)


- (((DONE))) Remove `target.description` field, and refactor target descriptions


- (((DONE))) Grubby refactor  GRUB-X: Limits money to $X!


- (((DONE))) Update mana visuals


- (((DONE))) Give mult-visual to slots


## ITEMS:

- (((DONE))) Simplify hammer items: 
"Earns X mult. Destroys a random target item"


- (((DONE))) ITEM: Demonic loan: (refactor)
On Buy: Earn $25
Destroy all target items
(shape=ROOK-10)

- (((DONE))) ITEM: Up Glove:
Gives UP-1 shape to item

- (((DONE))) ITEM:
Lose 0.1 multiplier
Earn 30 points

- (((DONE))) ITEM:
Multiplies points by -1. 
Adds 6 multiplier.
STICKY.

- (((DONE))) ITEM:
Set multiplier to -10
Spawns steak items in UP-3 shape
(note: the way this works, is the steaks will offset the -30 mult, to give a net benefit. The player may also modify the shape for even more benefits/synergies)

- (((DONE))) ITEM: Golden potion:
Buff target item's points-generated by the current balance.
(Currently: $X)


- (((DONE))) ITEM: Bread
If target item is DOOMED, transforms into target item
shape: ROOK-1


- (((DONE))) ITEM: Anvil:
Buff target items points-earned by the current mult (currently: X)

- (((DONE/DEFERRED))) ITEM: Jar of gold:
Generates 5 points
Increases price by $1
(^^^ Maybe we should replace golden_watch with this? Make it simpler)


- (((DONE))) FOOD ITEM: (burger?) Copies it's own target-shape to all target items.
(Currently: ROOK-1)
(Shape: ROOK-1)


- (((DONE))) ITEM: Earn +1 mult for every target item that is STUCK

- (((DONE))) ITEM: Increases price of all target items by $6 (Cost 1 mana)

- (((DONE))) ITEM:
Gives mult equal to the number of lives that this item has
[Gives +1 mult]
(starts with 1 extra life)

- (((DONE))) SLOT: Create interest-slot

- (((DONE))) SLOT: Swashbuckler Slot:
Items placed on this slot dont cost any money to activate (And cannot earn money either!)
(NOTE- use `destroy_slot_concept_2.png` for the image!)
Color should be gold tho, maybe...?

- (((DONE))) ITEM: Swashbuckler apple: Creates a swashbuckler slot

- (((DONE))) ITEM REFACTOR: Change ping-pong paddle. Its currently a bit... meh. Maybe something to do with mult, since it's red-colored?

- (((DONE))) ITEM CHANGE: Do something with FEATHER!
(we already have an item-def for it; its just that the current definition overlaps with white-cap. 
So change it to something new; thx.
Maybe something that costs mana...?)
IDEA-1: manaCost=2, gives x2 mult
IDEA-2: manaCost=1, gives +1 mult. Permanently increase mult by 1.


- (((DONE))) Item placement target-Juice:
https://discord.com/channels/@me/698376055140122624/1328663740203143198


- Make mult-increment / point-increment visual better;
--> (((DONE))) currently it disappears! It should bob up and down instead.
--> (((DONE))) fix the rounding (NOTE: we have a function for this: `showNSignificant`)

--> (((DONE))) FIX THE MULT NOT SHOWING!!! idk wtf is happening, but it aint working


- (((DONE))) Make mult-packet visuals!!
We have packet-visuals for points, but NOT for mult.  Change this.
(^^^ also maybe change the points-sprites back to the old-version..?)
(What about just a basic white square sprite as the packet?)


- (((DONE))) PROCEDURALLY GEN MANA ITEMS:::
Reduce item price by $4
Add 1 mana cost to it

- (((DONE))) Add coin-visual on top of items for when moneyEarned is negative!
(Grubby visual should have bronze coins, negative moneyEarned should be gold coins)

- (((DONE))) Make shoppy items sticky, nerf the shapes of them (especially balloons!)

- (((DONE))) Redo some of the money-items; some of them are bad.

- (((DONE))) Fix fullscreen crash: 
REPRO: Fullscreen game when in the NewRunScene (gets error due to stencil)

- (((DONE))) RELEASE PLAYTEST!!! (DONE DONE DONE)

