


# LUI REFACTOR:
```lua

keyPressed, keyReleased  ->  controlPressed, controlReleased
wheelmoved -> controlPressed

mouseMoved -> pointerMoved


mousepressed
mousereleased
-> --[[
wtf do we do with these???
There is quite tight coupling between this and the mouse-position...

Ok... for now, lets create `onClick`, `onClick
This is kinda ; because tbh, we need to make assumptions *somewhere*.
]] 
```


# ISSUE NUM-1:
Ok hmm...
Turns out we have a liiiittle bit of a dilemma here.

keypressed,keyreleased,mousereleased is propagated to all Elements.
wheelmoved is only propadated is the element is hovered.
mousepressed is only propagated if the element is hovered.

But... we are coagulating all of these into one.
So we need to have consistent propagation.

## SOLUTION:
For `controlPressed`, Use `isHovered` OR `isFocused` propagation.
This allows for great flexibility, without compromising any integrity.

For `controlReleased`, ALWAYS propagate.



# ISSUE NUM-2:
`:isClickedOnBy(button)`
Wtf do we do with this method?

I guess we should abstract it to controls...?
Ok, this would require us to emit `controlReleased` callbacks 
for wheels tho. Thats all goods.

new API:
```lua
Elem:isClickedOnBy(controlEnum)
- ->>>
Elem:isPressedOnBy(controlEum)
```
ok... but this kinda feels a biiiit *weeird*.

Because it's not about "clicks"... it's about controls.



