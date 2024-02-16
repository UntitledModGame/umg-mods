

-- args: (queryEnt, authEnt)
-- checks whether an entity (queryEnt) has permission to interact/access `authEnt`
umg.defineQuestion("permissions:entityHasPermission", reducers.OR)

-- args: (queryEnt, authEnt)
-- checks whether an entity (queryEnt) has permission to interact/access `authEnt`
umg.defineQuestion("permissions:isEntityPermissionDenied", reducers.OR)

