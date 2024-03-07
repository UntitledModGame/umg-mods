


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




# ISSUE NUM-3:
How do we do propagation/blocking correctly for clicks?

If we are hovering an inventory, we want CLICKS to be blocked.
BUT... we don't want `move:UP` to be blocked, for example.

How do we determine what does/doesn't get blocked?

IDEA: 
Ok... this is a bit hacky...
but we could just hardcode clicks to be blocked.

IDEA-2:
We could differentiate between pointer-controls, and "normal" controls.
Pointer controls are blocked iff the pointer is hovering the elem.
Normal controls are not blocked.


Lets break it down a bit:
We have a few main problems at large here:

Do we accept controls?
    - clicks: only if pointer contains
    - others: always.

Do we block controls?
    - clicks: only if pointer contains
    - others: only if the element blocks it explicitly

How do we tell if something is a click?
    We could hardcode it
    We could provide an API for checking
    Question-bus...?

- SOLN: Hardcode everything for now.
    Put TODOs where appropriate


How do we do `passThrough`?
(Do it the same as it was before)

