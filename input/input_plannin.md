
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


listener:onPress("ZOOM_IN", function(self)
    ...
end)
listener:onRelease("ZOOM_IN", function(self)
    ...
end)
listener:isDown(controlEnum)

listener:onControlPress(function(self, controlEnum)
    ...
end


listener:onUpdate(function(self)

end)

listener:onPointerMoved(function(self, dx, dy)
    -- ....
end)





local px, py = listener:getPointerPosition()
-- akin to :getMousePosition


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




# THINGS TO PLAN / PROBLEMS:

---

### `Pointer` abstraction:
We probably need to abstract the mouse as a `Pointer` object, or something.

So when controller support, we can have mouse/joystick be used interchangably through this abstraction.

---

### wheelmoved abstraction:
Some events pass extra info. For example, `wheelmoved` passes dx,dy values.
How do we handle these????

IDEA:

- Call `wheelmoved` control multiple times for each press
- Void the argument
    `wheelmoved`, we would just check the *sign* of the argument.





---

### LUI Scene dependency:
LUI Scenes are kinda dependent on the whole
`keypressed` / `keyreleased` thing....

we need to force an abstraction somehow.
Perhaps we only need a couple of cbs?
`mousepressed` --> `pointerpressed`


```

