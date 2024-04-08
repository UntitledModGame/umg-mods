
# Item-API and execution planning:

IDEA: Have no implicit buffering. Implicit = bad.
We should have tooling to help with buffering, tho.

```lua
defineItem({
    onActivate = function(ent)
        ... -- activates an item instantly
    end,


})
```


## Execution API:
```lua
defineItem({
    activate = function(ent)
        lp.Bufferer()
            -- a `Bufferer` is a data structure that executes code, buffered
            :touching(ent)
            :filter(func)
            :items()
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

