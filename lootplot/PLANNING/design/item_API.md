

## IDEA: Lets plan the API **BEFORE** we decide on the buffering behaviour.
```lua

defineItem({
    -- activate all other touching items:
    activate = function(ent)
        lp.getInRange(ent)
            :foreachBuffered(function(ppos)
                lp.activate(ppos)
            end)
    end
})



defineItem({
    -- activate all other touching items:
    activate = function(ent)
        lp.getInRange(ent)
            :foreachBuffered(function(ppos)
                if slot then
                    lp.destroy()
                end
            end)
    end
})




```


