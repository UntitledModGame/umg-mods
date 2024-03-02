
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
    "MOVE_RIGHT"
})


input.setControls({
    MOVE_LEFT = {"key:a", "key:left"},
    -- in future, could use `joystick:` namespace
    MOVE_RIGHT = {...},
    ...
    ...
})
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


