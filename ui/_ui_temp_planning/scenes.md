

## ===
# LUI REFACTOR
## ===



# LUI Scenes:

Should we keep LUI Scenes, 
or remove them?



## AMAZING IDEA:
Remove scenes, have elements be Scenes!







### View of top-level elements:
How should the size/position be determined for top-level elements?
- Should be left up to the implementor.

---
BUT, we still need a way to store the position of inventories, say.
(Previously, we used `draw_x` and `draw_y` values within the inv.)
A few ideas:
- Keep the `x,y` position inside of the entity thats controlling the LUI elem
    - (This way, the position is retained when the entity is saved)
    - IDEA: `uiX, uiY` components?
    - Or maybe a `uiPosition = {x=x,y=y}` component?

- The `w,h` should be determined by question-bus.
Perhaps using `reducers.PRIORITY` for `ui:getPosition`,
and then `reducers.ADD` for `ui.getPositionOffset`





### Focusing:
"Focusing" is an amazingly helpful mechanism.
Text-boxes, inventory-slots; etc:
There are many elements that would need this kind of mechanism.

Maybe "Focusing" is a too specific manifestation of a more general phenomena.
Is there something simpler/better that we can use?

I think focusing is fine...
It adheres to KISS.
We can always change it in the future.

---
Implementation:
To implement focusing, we should allow `Element`s to have ONE (1)
child that is "focused".


