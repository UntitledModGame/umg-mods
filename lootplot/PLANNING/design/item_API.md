
# Item-API and execution planning:

## Execution API:
```lua
defineItem({
    activate = function(ent)
        lp.Bufferer()
            -- a `Bufferer` is a data structure that executes code, buffered
            :touching(ent)
            :filter(func) -- func(ppos) -> bool
            :items() -- ppos-->item
            :execute(function()
                -- Do something with `touching` items:
                ...
            end)
    end
})
```

Should there be automatic buffering with this setup...?
but yeh, great thing about this: it's extendable

```lua
local CustomBufferer = objects.Class(name)
  :implement(lp.Bufferer)
  :implement(lp.CustomFunctions)

```

