
# SEASON 0 CONTENT PLANNING:



### Mechanics:

## ITEMS:
Plant items: (Plants can only spawn on `dirt` slot)
- item: spawns *grass-item* on all target dirt slots
- item: spawns blueberry-items on all target dirt slots
- item: generates +1 point for every target empty slot
- item: generates +2 points for every target plant item

Food items: (consumables)
- blueberry: gives +1 pointsGenerated to all target items (ONE TIME USE)  (shape=ABOVE_SHAPE)
- strawberry: gives +1 maxActivations to target item (ONE TIME USE)  (shape=ABOVE_SHAPE)
- item: Generates normal slots in a PLUS shape (ONE TIME USE)
- item: Clone the above slot into a KING shape (ONE TIME USE)
- item: Transforms below slot into a GOLD or DIAMOND slot (ONE TIME USE)

Destructive items:
- item: destroys target items, generates +5 points for each
- item: destroys target slots, earns $1 for each
- item: when destroyed, generates +10 points
- item: destroy all target items, permanently gain +0.2 pointsGenerated for each

Financial items; 
- item: earn 1 money
- item: earn money equal to 5% of current balance
- item: earn money equal to 50% of points generated of above item
- item: after 3 rounds, give 10 gold (ONE TIME USE)
- item: generate points equal to 20% of the current balance

Rulebender:
- item: when sold/destroyed, trigger all target items
- item: when activated, transform into above item
- gift-box: after 3 activations, transform into a rare item
- dollar-box: transform into a rare item that costs $1 to use
- pandoras-box: spawn a rare item in an ABOVE shape that has only 1 use

Emergent items:
- item: triggers pulse for all target items
- item: triggers reroll for all target items

Shape transformer items
- item: give rook shape to above item
- item: give king shape to above item
- item: give plus shape to above item

Swapper items:
- Star card: swap shapes of above and below items (ONE TIME USE)
- Diamonds card: swap traits of above and below items (ONE TIME USE)
- Clubs card: swap positions of above and below items


Slot generator/transformer items
- item: Convert the below slot into a shop slot
- item: Convert the below slot into a reroll slot
- item: Convert target slots into dirt slots
- item: Nullifies the below slot

Scaling items
- item: give +1 permanent pointsGenerated to a random target item

*SPECIAL ITEMS*: Cannot be obtained via random generation! Can only be spawned by other items
- grass-item: generates 1 point


## SLOTS:
- Gold slot: generates $1 on activation
- Diamond slot: pulses twice
- Glass-slot: has a 10% chance of breaking on activation
- Null-slot: doesn't activate
- Reroll-slot: self-explanatory
- Dirt-slot
- Shop-slot: self-explanatory
- Epic-shop-slot: Shop slot, always spawns items of epic-rarity or above. Only rerolls on `RESET` trigger.

## Button slots:
- Reroll-button: click to reroll. Cost=$2  (MAX-USES: 10)
- Activate-button: click to activate plot. Cost=$5  (MAX-USES: 10) yellow-question-mark button


-------------
-------------
-------------

## STRETCH-GOAL: Augment ideas:
- augment: increase maxActivations by 3
- augment: generate +4 points on activation
- cracked-augment: Is destroyed after X activations





# ============
# STUFF WE NEED AS OF 23/07/2024:
# ============
- We need a basic trait system
- We also need descriptions/naming for shapes
- Need descriptions for basic properties
- Need a rarity system, and pass a proper table to `generation:addEntry`
- Need `activateCost` component; for reroll-button














Fruit/food items: 
- Consumable items

Potion items:
- Consumable items that are POWERFUL/RULEBENDER

Dark items:
- Related to death somehow

Plant items:
- Related to spawning / growth

Yellow/golden coloured items:
- Related to money somehow

Armor (chestplate/leggings) items:
- Related to creating/destroying/modifing slots

Glove items:
- Related to changing/interfacing with shapes

Helmet items:
- Useless on their own
- Will always interact with other items heavily.
    - (IE: Works well with shapes!)


