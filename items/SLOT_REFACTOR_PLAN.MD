

# Slot refactor plan


FOCUSING:
We need a simple way to focus slots.
-->
Do we just use `scene:focus(slotElem)`...????

Where do we store the focused element?
Do we store it local to the system?
(Probably; because then the slot-system can handle faults.
For example, if an entity is deleted)



ITEM-DESC HOVERING:
We need a way to determining when we display item-descriptions.
Obviously, we want to display item-desc when an element is being hovered.
But...
By nature, the item-desc box needs to be global;
NOT nested inside an element.

How do we detect when a slot is being hovered..?
Oh, obvious, idiot. Use `startHover` / `stopHover` of `SlotElement`.
From there, dispatch to item-description system.
In fact, its probably best not to use `stopHover`, and just to check
`isHovered()` every frame inside of the item-description system




ITEM-DESC RENDERING:
We probably want a custom-text API for this.
For now, ignore custom-text API; just keep it simple.

we probably should create a new base mod for colored-text API, tbh.






