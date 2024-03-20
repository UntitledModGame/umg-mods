

# INSPIRATION FILE:
List of crazy/wacky ideas/mechanics that could be used:




# Modifiers:
"Modifiers" appear as a little image above the entity.
They signify some modifier upon the item/slot.
- Doomed: This will be destroyed in `N` rounds
    (Number will be shown when hovered)
- Exhalted: This will activate TWICE
- Coined: This will give $1 when activated
- Loaned: Lose $1 when this item activates. Cannot activate with no money.
- Nulled: This cannot activate



# Supers:
supers + comboslots: (todo: think of better name plz)
supers could be special items that are made by "merging" other items.
To create a super, you need to place "ComboSlots" next to each other,
and then place items in the ComboSlots.
For example:
Super-Clone-Gem: requires 2 rulebender, 1 primitive, and 1 legendary item

^^^ This would solve the "Bloat" issue.
Currently, a big "issue" with LOOTPLOT, (and tower-defences in general,)
Is that the map gets way more bloated, and harder to understand as the game
goes on.
The idea of `Supers` would solve this very well!! :)





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

- On reroll: Reduce all prices by 1

- End of round: Multiply shop prices by -1. Then, destroy this item.

- Gear: When rotated, rotate all touching items.
    (^^^ Remember to have `maxActivations` for this one!!!)
    (If we put 2 gears next to each other; infinite loop.)

- Piggy: Start of round: Gain +1 gold for every 10 gold you have.

- When item is cloned: 
    Transform the cloned item into the item that is above this item

- When item is destroyed: Give the above item `contagion`.
    - `contagion`: Start of round: 
        Clone self into all touching slots.



