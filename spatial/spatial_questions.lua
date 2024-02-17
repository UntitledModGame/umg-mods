

-- is velocity disabled for this entity?
umg.defineQuestion("spatial:isVelocityDisabled", reducers.OR)

-- Is vertical velocity disabled for this entity?
umg.defineQuestion("spatial:isVerticalVelocityDisabled", reducers.OR)

-- Is friction disabled? 
umg.defineQuestion("spatial:isFrictionDisabled", reducers.OR)




--[[
    What's the different between speed and velocity?

    speed = How fast an entity can move if it WANTS to move
        i.e. car turns on engine, drives down the road at 20 speed

    velocity = How fast an entity is ACTUALLY moving.
        Depends on environmental circumstances.
        i.e. car is thrown into orbit by a catapult.

    Car's max speed is 20, but it's velocity can still be bigger than 20.
]]
-- Gets the flat speed of an entity
umg.defineQuestion("spatial:getSpeedModifier", reducers.ADD)

-- Gets the speed multiplier of an entity
umg.defineQuestion("spatial:getSpeedMultiplier", reducers.MULTIPLY)


-- Gets the velocity multiplier of an entity
umg.defineQuestion("spatial:getVelocityMultiplier", reducers.MULTIPLY)

