
# health components

```lua


ent.health = 10

ent.maxHealth = 50 -- is a property!



ent.onDeath = function(ent)
    -- called when this entity dies
end


ent.lifetime = 5
-- this entity has 5 seconds left to live!
-- (This value will automatically count down until its dead)


```

