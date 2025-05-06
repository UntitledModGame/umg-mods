

# After-Release 2025 sprint

## DONE:

- Made sponge LEGENDARY
- Made red-fan LEGENDARY
- Made some gloves EPIC
- Fixed 8ball and L-ball
- Fixed purple-loaf being purple, made it match NEW shop slots
- Fixed map not working
- Fixed food items with "On Pulse" triggers
- Made stonefruits more expensive
- Nerfed bomb / 7-ball
- Fixed 2 turnip softlock  (Now, `foodItem`s only activate after move.)
- Fixed some speling/gramar erors
- Made green-squash clearer
- Made fortune-cookie float (usable on sacks now)
- (Tried to) Fix properties crash
- Fixed dark sack/bar crash (once and for all)
- Made sack-items less common
- Nerfed blue/red records
- Made fullscreen settings save, as well as width/height
- Fixed double-click crash
- Fixed nan analytics crash
- Made number display better for large nums
- Added SKIP trigger
- Removed LEVEL-UP trigger


## =============================
## TODO:
## =============================



- New item: GOLDEN FISH: Sets money to -$20, Makes slot earn $1

- New item: BLUE FISH: Set money to -$10, Makes slot earn 8 bonus

- New item: SALMON: ($1) Rotate and trigger pulse on items.
(KING-1 Shape, UNCOMMON)

- Made golden horseshoe be an UNCOMMON food item (as well as non-food)


- Removed the next-level button, BIG REFACTOR to pulse-button / rounds
---->>>
- Instead, the Pulse-Button BE the next-level button. (including visuals)
- The player should receive $10 for every round completed early.
- (Make sure to buffer the cash, just like interest-slot so the player can see how much they get)
- ALSO: MAKE SURE TO DO THE DESCRIPTIONS WELL!!!!

NEW SYSTEMS/COMPONENTS: 
- PROPERTY: "Only activates on the final round!" (Mineral mirror item???)
- lp.defineAttribute("SKIPPED_ROUNDS") -- number of rounds skipped
- ITEM: Earns +X mult (X = how many rounds skipped)
- ITEM: Earns +X bonus (X = how many rounds skipped)
- ITEM: Gives items +X points (X = how many rounds skipped)
- FOOD-ITEM: Earns $X (X = how many rounds skipped) 
^^^^ (these should use SKIPPED_ROUNDS attribute)


- Create popup text saying "LEVEL {X} PASSED!"

- Play a cool sound when progressing to next level


- Ghost-knife, Moon-knife, etc will need buffs


- New food-item: 50% chance to destroy slot. 40% Chance to earn $5. 10% Chance to spawn a KEY.
^^^ really nice since this allows you to clear slots. Also fun gambling lol


- Made LEGENDARY-items spawn inside of locked-slots 
(inside cloud-slot; that way, the cool fire effect is visible )


- Nerfed Diamond-slot to 3x bonus

- Adjusted ruby-items to 3 activations, buffed points/strength

- Golden ornament nerfed (only earns $0.5)


- Added 3 new trophies, bronze, silver, gold

- Added 3 new difficulties; (easy, medium, hard)

- Added 2 new DOOMED-10 items so the archetype isn't completely dead

- Reworked hammers; have xStrength mult when bonus is negative

- Created Grubby-ball, (G-ball) showcasing grubby-archetype
- Created achievement for grubby-ball

- Created sapphire-ball (S-ball) showcasing anti-bonus archetype
- Created achievement for sapphire-ball

- Made items that can't activate grayscale (need shader)

- CREATED NEW LEGENDARY ITEM: Chef's Knife: 
- On Level-Up: Spawns null-slots with food inside them. (KNIGHT shape)


- Added 2 extra difficulties- bronze, silver, gold trophies (to implement, create a "DIFFICULTY" property)
trophies should spawn more or less curses (silver trophy, 1 curse per level) (gold trophy 2 curses per level)
And the points requirement should differ too

