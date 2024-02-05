

-- Gets a controller clientId for the entity passed in.
-- Answers should return a valid client_id
umg.defineQuestion("sync:getController", reducers.PRIORITY)


-- Returns true if this entity's control should be blocked.
-- False otherwise.
umg.defineQuestion("sync:isControlBlocked", reducers.OR)

