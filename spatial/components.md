
# Components
List of components defined in the `spatial` mod:

```lua

ent.x
ent.y -- position components
ent.z  -- (z is optional)

ent.vx
ent.vy
ent.vz -- velocity components


ent.dimension = "overworld"
-- optional;
-- if dimension is nil, entity defaults to overworld



------------------
-- Properties:
-- (See the properties mod!!!)
ent.speed = 100 -- The speed the ent moves at

ent.agility = 0.9 -- How fast the ent can change it's speed.
-- Is a number between 0 and 1.
-- 1 = 100% agility, changes speed instantly
-- 0 = 0% agility, cannot change speed

ent.friction = 3.15 -- friction number. (default is roughtly 3.15)


```
