

"Augments" are entities that describe custom modifiers.
Augments can be applied to slots OR items.

Entities will naturally spawn in the shop with augments, OR, they may be
applied by other entities.

---

# 3 types:
- Slot augments
- Item augments
- Dual augments (work on BOTH items AND slots)

---

## Dual augments:
These augments must be generic in how they are displayed. 
We can’t put a corner tab on an item! that would look wrong.

INSTEAD: We use other visuals:
```
color
opacity
position (ie: bobbing up and down, or shaking)
scale (pulsing in size? spinning?)
```

## Slot augments:
Specific to slots.
could be characterized by an overlay upon the slot.
(For example, a lil corner flap-sprite at the bottom-left or something)

## Item augments:
Specific to items.

---



# Augment triggers:
*Augment triggers is the most beautiful/powerful thing about augments:*
--
Items only have one activation mode.
But augments can contain their own activation modes! They can also contain their own triggers.
--
So if a `REROLL` trigger doesn't apply on the item, it still may get propagated to the augment, and the item might do something!
This is really powerful and cool!!!


---

# Why do we have slot and item augments????
The advantage of having typed augments is that augments can be more aggressive about what effects they have on the ent. For example, slotAugments can directly influence behavior that is specific to slots

```lua
lp.defineSlotAugment(name, {
  ...
})

lp.defineItemAugment(name, {
  ...
})
```








# OLD IDEAS:

## Regular Augments:
- Delicate: Will be destroyed when rotated
- Fragile: Will be destroyed when moved
- Dicey: Will reroll at the start of the round
- Explosive: When destroyed, will destroy touching items
- Nulled: This cannot activate
- Sticky: This item cannot be sold/destroyed
## Variable Augments:
- Revive-X: When destroyed, will revive itself X times, as a clone
- Doomed-X: Dies after X rounds
- Blessed-X: Will activate X times
- Golden-X: Gives $X when activated
- Loaned-X: Lose $X when activated. Cannot activate with no money

