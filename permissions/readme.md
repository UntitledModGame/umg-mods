

# Permissions mod:

Handles all kinds of permissions.

- Handles admin-privaledges for clientIds
- Also, provides a nice API for "permissions" for entities... 
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

## API:

### Entities:
```lua

-- Flag components:
authorizable
-- Denotes that the entity is `authorizable`

local hasAccess = permissions.entityHasPermission(queryEnt, authEnt)

-- args: (queryEnt, authEnt)
question("permissions:entityHasPermission", reducer=OR)
question("permissions:isEntityPermissionDenied", reducer=OR)

```

### Client admin-levels:
```lua

local level = permissions.getAdminLevel(clientId)
permissions.setAdminLevel(clientId, level) -- serverside only

```

