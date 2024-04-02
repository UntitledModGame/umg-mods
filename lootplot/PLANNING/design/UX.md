

# Slot interaction
Slots are the FOUNDATION of lootplot.
And they are (very) important to get right... 
because they are the ONLY way that the player can interact with the world.


## Interaction plan:
At the base-level, there is ONE base interaction:
- Click on a slot

### What happens when we click on a slot?
- If clicked slot doesn't have an item: 
    - Don't select it.
- Else:
    - If another slot is selected, and BOTH slots have movable items:
        - Swap the items in the slots
    - Else: 
        - Select the slot that was clicked



### Shops / selling:
How do shops/selling work with this...???
---->
When a slot-item is selected, a UI-buttons should pop-up at the bottom:
Buttons:
```
sell ($X)   [only appears if item/slot is sellable]
buy ($X)    [only appears if slot is buyable]
cancel  (will deselect slot)
```
**SUPER IMPORTANT:**
Make sure to keep this API extendable!!!
We should allow for more buttons in the future;
other mods should be able to introduce their own buttons/UIs too.

### Awesome example:
`Lock Reroll` button toggle; available to some reroll-slots.
When a slot is "locked", it prevents the item from being rerolled.

^^^^ Ideally, we should try implement `Lock Reroll` as an external mod,
just to ensure that the API is extensive enough.



