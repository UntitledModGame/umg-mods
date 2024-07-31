
# SEASON 0 CONTENT PLANNING:



### Mechanics:

KEY: ^ = havent got image yet!

## ITEMS:
Botanic items: (Plants can only spawn on `dirt` slot)
- ^Grass seeds: spawns *grass-item* on all target dirt slots
- ^Blue seeds: spawns blueberry-items on all target dirt slots
- ITEM: generates +3 points for every target empty slot
- ITEM: generates +5 points for every target plant item

Food items: (consumables)
- blueberry: gives +1 pointsGenerated to all target items (ONE TIME USE)  (shape=ABOVE_SHAPE)
- lychee: gives +1 maxActivations to target item (ONE TIME USE)  (shape=ABOVE_SHAPE)
--- Slot-food items:
- Pomegranate: Generates normal slots in a KING shape (ONE TIME USE)
- Apple: Transforms below slot into a GOLD or DIAMOND slot (ONE TIME USE)
- Gapple: Clones the above slot in a KING shape (ONE TIME USE)
- Red cap: when sold/destroyed, pulse all targets
- Green cap: when sold/destroyed, reroll all targets
- Purple cap: when sold/destroyed, transform into a random target item
- Magic radish: when activated, transform into above item

Destructive items:
- Dark skull: destroys target items, generates +5 points for each
- Profit purger: destroys target slots, earns $1 for each
- Dark flint: when destroyed, generates +10 points
- Reaper: destroy all target items, permanently gain +0.2 pointsGenerated for each
- Empty couldron: destroy all target slots, gain +5 points for each

Fiscal items; 
- Gold sword: earn 1 money
- King ring: earn money equal to 5% of current balance
- Gold Axe: earn money equal to 50% of points generated of above item
- Golden fruit: after 3 activations, give 10 gold (ONE TIME USE)
- Bishop ring: generate points equal to 20% of the current balance

Rulebender:
- ^Gift-box: after 3 activations, transform into a rare item
- ^Dollar-box: transform into a rare item that costs $1 to use
- ^Pandoras-box: spawn a rare item in an ABOVE shape that has only 1 use
- ^Boomerang: +1 points. Uses all activations at once.
- ^Glass-potion: +1 points. Uses all activations at once.
- Red shield: triggers pulse for all target items
- Green shield: triggers reroll for all target items

Glove items: (Shape transformers)
- Quartz glove: give rook shape to above item
- Ruby glove: give king shape to above item
- Copper glove: give plus shape to above item
- Wooden glove: give plus shape to above item

Card items: (Swappers)
- Star card: shuffle shapes of target items (ONE TIME USE)
- Diamonds card: shuffle traits of target items (ONE TIME USE)
- Spades card: Shuffle positions of target items

Book items: (Slot transformers) (Default shape=ABOVE)
- Book of basics: Convert target slots into normal slots
- Book of shopping: Convert target slots into shop slots
- Book of rerolling: Convert target slots into reroll slots
- Book of farming: Convert target slots into dirt slots
- Empty book: Coverts target slots into NULL slots

Scaling items
- spartan_helmet: give +1 permanent pointsGenerated to a random target item

*SPECIAL ITEMS*: Cannot be obtained via random generation! Can only be spawned by other items
- grass-item: generates 1 point


## SLOTS:
- Gold slot: The only slot-type that can hold LEGENDARY items.
- Diamond slot: pulses twice
- Glass-slot: has a 20% chance of breaking on activation
    - NOTE: Glass-slots are REALLY easy to generate!
    - (eg. generate glass slots in a ROOK shape)
    - But they are risky, since they will destroy your items.
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


