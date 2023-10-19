

# EFFECT ABSTRACTION:

Could it be possible to reduce the coupling between `EffectHandler`
and `effect`/`passive` entities to zero?

Similar to how `usables` was de-coupled from the `Inventory`...?

^^^ If this is too difficult, dont do it.
But PLEASE. At least try to do it this way.
take the `usables` and `Inventory` de-coupling as the golden example.

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
    - IDEA-1: store it inside `.propertyEffects`
    - IDEA-2: store inside of `ent.effects` -> `ent.effects.property`

Do we even need `EffectHandler`?

A: Yes, it probably makes sense to have a central object
just to keep things robust and readable.



