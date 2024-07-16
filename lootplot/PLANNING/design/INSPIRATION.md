

# INSPIRATION FILE:
List of crazy/wacky ideas/mechanics that could be used:





## SUPER-WEAPON: Generic Augments/Modifiers!!!
REMEMBER TO ABUSE THE ECS-NATURE OF LOOTPLOT!!
Tried to make as many components as possible be generic; that is, works on both slots and items.






# Supers + Combo-slots:
supers + comboslots: (todo: think of better name plz)
supers could be special items that are made by "merging" other items.
To create a super, you need to place "ComboSlots" next to each other,
and then place items in the ComboSlots.
For example:
Super-Clone-Gem: requires 2 rulebender, 1 primitive, and 1 legendary item

^^^ This would solve the "Bloat" issue.
Currently, a big "issue" with LOOTPLOT, (and tower-defences in general,)
Is the map gets too bloated/hard to understand as the game progresses.
The idea of `Supers` would solve this very well!! :)

(Scaling items also help to solve the bloat issue too.)





# FUEL ITEMS
Some items should act more as fuel then regular items.

## For example:
Compost bin:
If targeting 4 botanic items, delete all target items and generate 15 points
-->
Manure: (has botanic trait)
This item does nothing.
its main purpose is to be used as "fuel" (by compost bin in this scenario)





## World slots:
Buyable slots/rerollable slots should be able to exist in the WORLD PLOT.
This... would be extremely beautiful.
ALSO! This would also allow us to implement the shop for FREE;
since the shop would just be a regular inventory, with reroll+buyable slots.

- When entity dies in a slot:
    Spawn a legendary item in the slot, 
    and turn this slot into a buyable slot, costing $5
^^^ 




# Items:
- Clone the item above into the slot below

- When entity is purchased: cause a reroll

- Round end: kill all the items around this entity

- End of round: Multiply shop prices by -1. Then, destroy this item.

- Gear: When rotated, rotate all touching items.
    (^^^ Remember to have `maxActivations` for this one!!!)
    (If we put 2 gears next to each other; infinite loop.)

- Piggy: Start of round: Gain +1 gold for every 10 gold you have.

- Lucky charm: if a rare item is spawned in range, convert it to LEGENDARY.

- Compost: convert all `botanic` items in range to `fertilizer`.

- When item is cloned: 
    Transform the cloned item into the item that is above this item

- When item is destroyed: Give the above item `contagion`.
    - `contagion`: Start of round: 
        Clone a `doomed` self into all touching empty slots, 
            and remove `contagion` augment.

- End of round: Create `doomed` slots in a ROOK shape. 
    Does not overwrite.

RULEBENDER IDEA:
This item doesn't do anything on its own.
However, it has two buttons bound to it:
    - Copy: Copies the current plot
    - Paste: Returns the plot to its saved state, and deletes all items of type `self`

