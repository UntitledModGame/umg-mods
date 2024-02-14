


## API:
```lua

ui.open(uiEnt)
local bool = ui.canOpen(uiEnt)

ui.close(uiEnt) -- closes UI

```


## Events / Questions:
```lua
event("ui:elementOpened", ent)
event("ui:elementClosed", ent)


-- args:  (uiEnt, clientId)
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

