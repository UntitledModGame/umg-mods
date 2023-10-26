

# components


```lua

-- The set of effects that an entity has:
ent.effects = objects.Set({ effectEnt1, effectEnt2, ... })
-- This component is managed INTERNALLY!! Do not edit this directly!
-- Use effects.addEffect / removeEffect instead.









--[[
=================================
Effect entities:
=================================
]]

ent.effect = true
-- This tells the system that `ent` is a valid effect entity.


ent.propertyEffect = {
    -- this effect will cause the target entity to have 1.5x strength,
    -- AND +10 strength.
    property = "strength",
    multiplier = 1.5,
    modifier = 10,
}




ent.eventEffect = {
    event = "damageEffectEvent",

    trigger = function(ent, ownerEnt, damage)
        print("triggered, with damage: ", damage, ...)
    end,

    shouldTrigger = function(effectEnt, ownerEnt, damage, ...)
        return damage > 1 -- whether the event effect should occur
    end
}



ent.questionEffect = {
    question = "getProjectileTypeEffect",

    answer = function(effectEnt, ownerEnt, ...)
        return "plasma" -- `plasma` entity type
    end,


    shouldAnswer = function(effectEnt, ownerEnt, ...)
        return true
    end
}




-- an effect entity with nested effects:
-- (this allows us to "combine" effects.)
ent.nestedEffect = {
    effectEnt1, effectEnt2, ...
}



```
