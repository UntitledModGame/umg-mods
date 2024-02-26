

-- args: (actorEnt, authEnt)
-- checks whether an entity (actorEnt) has permission to interact/access `authEnt`
umg.defineQuestion("permissions:entityHasPermission", reducers.OR)

-- args: (actorEnt, authEnt)
-- checks whether an entity (actorEnt) has permission to interact/access `authEnt`
umg.defineQuestion("permissions:isEntityPermissionDenied", reducers.OR)

