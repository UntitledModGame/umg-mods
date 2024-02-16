

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

local hasAccess = permissions.clientHasPermission(clientId, targetEnt)
local hasAccess = permissions.entityHasPermission(authEnt, targetEnt)

-- args:  (clientId, targetEnt)
question("permissions:clientHasPermission", reducer=OR)
question("permissions:isClientPermissionDenied", reducer=OR)

-- args: (authEnt, targetEnt)
question("permissions:entityHasPermission", reducer=OR)
question("permissions:isEntityPermissionDenied", reducer=OR)

```




# Further planning:

It would be *really damn nice* to be able to check on a per-entity basis.
Ie:
"does entA have permission to access entB?"
Then, we could do stuff like:
`grant access when within 100 units` or somethin.

