

# Flag components:


# `interfacable`:
```lua
ent.interfacable --- >>>>
-- the following methods can be called on ent:
ui.openInterface(ent)
ui.closeInterface(ent)

local bool = ui.canOpenInterface(ent)
-- whether the client can open the interface


-- by default:
components.project("uiElement", "interfacable")
```


