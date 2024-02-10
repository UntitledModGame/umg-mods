

# Feature Wishlist:



- Stuff can get automatically implemented for UI elements
    (like plugins/mixins)
- Dragging UI elements around should be implemented automatically by a mixin

- Should be SUPER easy to sync stuff to server --> 
- Need easy way to bind entities to LUI elements,
(for use w/ `usable` comp.)



*Inventories:*
- Item tooltips should be extendable (<--- might be difficult)



# MAIN WISH:
- KEEP IT SIMPLE.
- KEEP IT EXTENDABLE.
There have been *countless* times where you have implemented something,
and had to delete it after.

You should try as hard as possible to just keep it SIMPLE, AND EXTENDABLE.




# AWESOME IDEA:
Modify LUI
Add a "UMG Flavor" to the LUI library.

Ideas:
- ALL root LUI Elements have to be bound to an entity in some form.
    - (Nested LUI Elements aren't required to have an entity, however)

- `Element:getEntity()` function
    - Gets the entity that this Elem belongs to.
    - walks up the element tree if needed


- LUI Elements emit events / questions:
Questions:
`ui:isOutsideBounds ( elem, x, y ) -> bool `
^^^ useful for putting holes in container and stuff
`ui:isFocusBlocked  ( elem ) -> bool `
`ui:getSizeMultiplier  ( elem ) -> mulX, mulY `
`ui:getSizeModifier ( elem ) -> dx,dy`

Events:
`ui:elementFocus ( elem )`
`ui:elementUnfocus ( elem )`
`ui:elementRender ( elem, x,y,w,h )`

^^^ 
Surely we can think of some 





