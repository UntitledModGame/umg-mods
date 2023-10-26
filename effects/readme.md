
# Effects mod

Provides an API for effects to be applied to entities.

For example:
```
+ 10 health, -20% speed
```
This ^^^ is an example of an effect.

Effects can manifest in many different forms.<br/>
They may be a potion, an armor-piece, an upgrade-item, or a wearable trinket,
or anything else. It's kept very abstract!



---------------

## Entities that get effected by stuff:
```lua

-- The set of effects that an entity has:
ent.effects = objects.Set({ effectEnt1, effectEnt2, ... })


```

----------


# Effect entities:
Effects are just entities!<br/>
This allows us to have a bunch of cool, custom behaviour, and it also
allows our effects to be stateful in a clean fashion.
```lua

ent.effect = true
--[[
    this tells the system that `ent` is a valid effect entity.
]]

```


There are 3 core types of effects:
- Property effects
- Event effects
- Question effects

(But you can define your own if you want too.)

----------

## Property effects:
Property-effects are used to modify `properties` on entities.

For example:<br/>
- Gain +10 strength
^^^ This is a valid property-effect! Other examples:
```lua
ent.propertyEffect = {
    -- this effect will cause the target entity to have 1.5x strength,
    -- AND +10 strength.
    property = "strength",
    multiplier = 1.5,
    modifier = 10,
}


-- Exact same as before, but using functions instead:
-- This allows us to do more exotic calculations! :)
ent.propertyEffect = {
    property = "strength",
    shouldApply = function(ent, ownerEnt)
        return true -- (if returns false, this effect doesnt apply)
    end,
    multiplier = function(ent, ownerEnt)
        return 1.5
    end,
    modifier = function(ent, ownerEnt)
        return 10
    end
}

-- For propertyEffects, we can also use multiple rules:
-- (This is useful if we want +5% health, -2% speed or something)
ent.propertyEffect = {
    {
        property = "strength",
        multiplier = 0.9
    },
    {
        property = "strength",
        modifier = 10
    },

    {
        -- we can fit multiple ways of modifying per table too:
        property = "maxHealth",
        modifier = 10,
        multiplier = 1.1
    }
}

```


## Event effects:
Event effects occur whenever an event happens.
For example:

When entity takes damage:
    Print something in console
```lua
ent.eventEffect = {
    event = "damageEffectEvent",

    trigger = function(ent, ownerEnt, damage)
        print("triggered, with damage: ", damage, ...)
    end,

    shouldTrigger = function(effectEnt, ownerEnt, damage, ...)
        return damage > 1 -- whether the event effect should occur
    end
}
```
But, we aren't done yet!
We still need to actually forward the event through the effects mod:
```lua
umg.on("mortality:entityDamaged", function(ent, dmg)
    effects.tryCallEvent(ent, "damageEffectEvent", dmg, ...)
    -- We can pass extra args if we want! (denoted by ... )
end)
```
(The reason we do this manually, is that for some events, the effect-ent may not neccessarily be the first argument.)

---------------



## Question effects:
Same as Event-effects, but for question buses.
For example:

Shoot plasma instead of bullets.
(Tags into `projectiles:getProjectileType` question)
```lua

ent.questionEffect = {
    question = "getProjectileTypeEffect",

    answer = function(effectEnt, ownerEnt, ...)
        return "plasma" -- `plasma` entity type
    end,

    shouldAnswer = function(effectEnt, ownerEnt, ...)
        return true
    end
}
```
And likewise, we need to forward the question:
```lua
umg.on("projectiles:getProjectileType", function(shooterEnt, holderEnt)
    effects.tryCallEvent(holderEnt, "getProjectileTypeEffect", ...)
    -- we can also pass xtra args if we want, specified by (...)
end)
```



