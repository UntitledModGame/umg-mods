

## THE ACTION PROBLEM:
For `triggerEffects`, where do we keep the action?

I feel like it's a bad idea


## Solution:
Rename `usables` mod to `holdables` mod.

From there, change `usables` to be more generic;

A `usable` entity is an entity that can be "used" by another entity.
`usable` entities have instantaneous usage. They are not continuous.

For example:
- usable-items
- abilities
- consumables
- effect-actions


# ---------
# SOLVED: Create the `usables` mod
# ---------

