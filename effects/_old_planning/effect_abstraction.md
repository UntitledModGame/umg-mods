

# EFFECT ABSTRACTION:

Could it be possible to reduce the coupling between `EffectHandler`
and `effect`/`passive` entities to zero?

Similar to how `holdables` was de-coupled from the `Inventory`...?

^^^ If this is too difficult, dont do it.
But PLEASE. At least try to do it this way.
take the `holdables` and `Inventory` de-coupling as the golden example.

-------------------

## ATTEMPT-0

Ok.

After a bit of playing around in the problem space,
I think this may be possible.
(I actually think its trivial)

- Take for example, `propertyEffect`.

The idea would be to have the `EffectHandler` be an abstract effect holder, dispatching abstract events and holding abstract effects.

-------------------

# IDEA:

-------------

How about we have something similar to inventory SlotHandles: `EffectHandle`?

- ONE BIG DIFFERENCE:
For `SlotHandles`, it makes sense for SlotHandles to be different per-object; therefore, we allow them to be different per-object.

But for `EffectHandles`, everything has the same type.
They all have `PropertyEffectHandler`


## Two questions:
- How do we tell `PropertyEffectHandler` that an effect was added?
    - IDEA: through `effects:addEffect` / `effects:removeEffect`
- Where do we actually store `PropertyEffectHandler`...?
    - IDEA-1: store it inside entity:  `ent.propertyEffects`
    - IDEA-2: store it inside of `EffectHandler`


## API-DRAFT-0:
```lua

-- add/remove effects:
effects.addEffect(ent, effectEnt)

effects.removeEffect(ent, effectEnt)

```


But we still have an issue with defining EffectHandles:
## EffectHandle idea 0:
```lua
-- propertyEffect system:
umg.on("effects:addEffect", function(ent, effectEnt)
    assert(ent.effectManager, "this should be added by now")

    if effectEnt.propertyEffect then
        -- ensure we have propertyEffectHandler:
        ent.effectManager:ensureHasEffectHandle(PropertyEffectHandle)
    end
end)
```
^^^ This way *could* work...? Its not TOO bad.

## EffectHandle idea 1:
Define effectHandlers like similar to `sync.syncComponent`
```lua

effects.defineEffect("propertyEffect", PropertyEffectHandler)

```
What would happen here internally is that the `effectManager`
would get a `PropertyEffectHandler` given to itself, upon receiving
an entity with `propertyEffect` type.

This would also call `components.project("propertyEffect", "effect")` internally too.

This doesn't feel perfect, though. Mainly because the `eventEffectHandler` and `questionEffectHandler` are going to struggle.
Would there be a better way...?


## EffectHandle idea 2:
Define effectHandles as named:
```lua
effects.defineEffectHandler(PropertyEffectHandler)
```
Every `EffectHandler` class needs to define a `shouldTakeEffect` static method. This will be called from a static context by the EffectManager.

Ok. This is probably the best approach.

The reason this works well, is because then, we can access each `effectHandler` directly:
```lua
umg.on("mod:event", function()
    if ent.effectManager and 
        ent.effectManager:getHandler(PropertyEffectClass) then
        ...
    end
end)
```

# ---------
# SOLVED: We will use `EffectHandle idea 2`
# ---------

