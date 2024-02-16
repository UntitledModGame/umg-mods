

# Permissions mod:

Gives a nice, abstract way to grant entities "permissions".

For example:
```
- chest
- button
- door
- portal
- vehicle
```
These are all entities that could be granted "permission" to use.

Direct examples:
- a chest that can only be accessed by humanoid entities.
- a button that can only be pressed by players in a certain team.
- a portal that can only be used during night-time

## IDEA:
```lua
-- Flag components:
authorizable
-- Denotes that the entity is `authorizable`

local level = permissions.getAdminLevel(clientId)
permissions.setAdminLevel(clientId, level) -- serverside only

local hasAccess = permissions.entityHasPermission(queryEnt, authEnt)

-- args: (queryEnt, authEnt)
question("permissions:entityHasPermission", reducer=OR)
question("permissions:isEntityPermissionDenied", reducer=OR)

```

