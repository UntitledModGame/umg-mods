


## API:
```lua

ui.open(uiEnt)
local bool = ui.canOpen(uiEnt)


-- opening
ui.openWith(uiEnt, controlEnt)
local bool = ui.canOpenWith(uiEnt, controlEnt)


ui.close(uiEnt) -- closes UI

```


## Events / Questions:
```lua
event("ui:elementOpened", ent)
event("ui:elementClosed", ent)


-- args:  (uiEnt)
question("ui:canOpen", reducer=OR)
question("ui:isOpenBlocked", reducer=OR)

-- args:  (uiEnt, controlEnt)
question("ui:canOpenWith", reducer=OR)
question("ui:isOpenWithBlocked", reducer=OR)
```




## Components:
```lua

uiPermissions = {
    public = true,
    adminOnly = true,
    
}

```

