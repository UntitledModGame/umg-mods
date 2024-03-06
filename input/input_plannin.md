
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

    "INTERACT",

    "ZOOM_IN",
    "ZOOM_OUT"
})


input.setControls({
    MOVE_LEFT = {"key:a", "key:left"},
    -- in future, could use `joystick:` namespace
    MOVE_RIGHT = {...},
    ...
    INTERACT = {"mouse:1"}
    ...
    ZOOM_IN = {"scroll:down", "key:["}
    ZOOM_OUT = {"scroll:up", "key:]"}
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
ControlManager: handles mapping of controlEnum <-> keyboard/mouse/joystick
    Handles locking of inputs too
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
`mousepressed` --> `onPointerPress`

`keypressed` --> `onControlPress`...?





## OK: How do we handle locking of input???
We have 2 options here.
- lock via `inputVal`
- lock via `controlEnum`

lock via `inputVal`:
PROS:
It's slightly more robust, since its done at source
CONS:
We can no longer have `listener:lockControl(controlEnum)` api;
since there's no way to know what `controlEnum` is being locked.

Ok.
its obviously a good idea to have locking via controls.
-- ((SOLVED))




## PROBLEMO 2:
We need to dispatch events to the listeners...
But... currently, the ControlManager doesn't know about the listeners.

What would be a clean way to backpropagate this information?
- Use a simple callback (quick and dirty, easy)
    - pass in via ctor even?
- Pass in a `pass` argument to the `:wheelmoved` and stuff...?
    - nawww, i dont like this
- ControlManager could statically call some method
    - this is "fine", but it doesnt really "fit" with the current setup

for now, lets just pass callbacks into ctor. 
*definitely biased based off of umgclient state-refactor, but thats OK x)*





## PROBLEMO 3:
We need to iterate listeners in order... or else locking won't apply to update checks.

OK: Lets map out the problem space just a lil bit:
With our current setup:
We *kinda need* to listen to events as soon as they occur.
But we can still do buffering upon the events... because that's already been done

```lua
for _, listener in ipairs(sortedListeners) do
    for event in eventList do
        pollEvents(listener)
    end
    
    if listener.update then
        listener:update(dt)
    end
end
```
Idea:
Don't buffer input-events.   
Instead, buffer control-events directly.

Then, we can iterate over the controlBuffer and it'll work great.
```lua
local function pollEvents(listener)
    for _, controlEvent in ipairs(controlEventBuffer) do
        if listener[event.type] then
            local isLocked = isEventLocked(event.type, event.args, listener)
            if (not isLocked) then
                local func = listener[event.type]
                assert(type(func) == "function", "listeners must be functions")
                func(listener, unpack(event.args))
                -- ensure to pass self as first arg 
            end
        end
    end
end
```



## PROBLEMO 4:
How do we handle textinput?

Simple solution: simply emit a `onTextInput` event into Listeners,
with very little overhead.
With this, we will also need the InputListeners to be able to lock the entire input family (key, in this case)

----
Ok but we probably want to provide a very high-level access to locking
text-input directly.
Something like:
```lua
inpList:lockTextInput()
```



