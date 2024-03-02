
# planning:

We want `input` to be compatible with controllers in the future.
Also, we want controls to be changed easily :)

This mod intends to allow for that.


## NEW API:
New functions we need to create:
```lua

input.defineControls({
    "MOVE_UP",
    "MOVE_DOWN",
    "MOVE_LEFT",
    "MOVE_RIGHT",

    "ZOOM_IN",
    "ZOOM_OUT"
})


input.setControls({
    MOVE_LEFT = {"key:a", "key:left", "mouse:1"},
    -- in future, could use `joystick:` namespace
    MOVE_RIGHT = {...},
    ...
    ZOOM_IN = {"scroll:dy-", "key:-"}
    ZOOM_OUT = {"scroll:dy+", "key:+"}
})


listener:on("ZOOM_IN", function(self)

end)


listener:onUpdate(function(self)

end)


listener:


```

---


## Changes:
Change `inputEnum` to `controlEnum`:
```lua
Listener:lockInputEnum -> Listener:lockControl

Listener:isKeyLocked -> remove.
Listener:isMouseButtonLocked -> remove.
Listener:getKey -> remove.
Listener:getMouseButton -> remove.
Listener:getMouseInputEnum -> remove.

Listener:lockKey -> remove.
Listener:lockMouseButton -> remove.
Listener:lockInputEnum -> remove.

```

---

## Internal restructuring:
We should create a new "lock" API, for internal use.
This allows us to decouple stuff from the monolithic `input` file.

IDEA:
Have 2 systems:
```lua
InputLocker: handles locking of keyboard/mouse/joystick
ControlManager: handles mapping of controlEnum <-> keyboard/mouse/joystick
```



---

# `Pointer` abstraction:
We probably need to abstract the mouse as a `Pointer` object, or something.

So when controller support, we can have mouse/joystick be used interchangably through this abstraction.



---

# PROBLEMS:
LUI Scenes are kinda dependent on the whole
`keypressed` / `keyreleased` thing....

we need to force an abstraction somehow.
Perhaps we only need a couple of cbs?
`mousepressed` --> `pointerpressed`


```
