

## IDEA:
Decouple "UIs can be opened" with "interactable" behaviour.
Ie, when calling `ui.open(uiEnt)`, the ui mod doesn't check whether `uiEnt`
is interactable by the clientId.

This reduces coupling, and is quite nice.
Could even create a new mod...?

`permissions` mod?
```lua
-- Flag components:
authorizable

local level = permissions.getAdminLevel(clientId)
permissions.setAdminLevel(clientId, level) -- serverside only

local hasAccess = permissions.entityHasPermission(authEnt, targetEnt)

-- args: (authEnt, targetEnt)
question("permissions:entityHasPermission", reducer=OR)
question("permissions:isEntityPermissionDenied", reducer=OR)

```

