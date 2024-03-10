
# Attachment mod

We should be able to “attach” entities to other entities, to allow for bigger, cooler structures.

JUICE's IDEA:
```
I think it'd be sick if you could make
groups of entities into a single greater entity
through modular parts
```

You could imagine this as a giant mech running around, with mechanical arms, weilding multiple miniguns and stuff, and having entities orbiting around them. This would be really cool.

# For example:
```
Effect:
When active,
2 shields will orbit you and absorb damage
```

Also, we should add an API to integrate this nicely with other systems:
```
Effect:
All attached entities gain +5% damage
```

## Interesting idea:
We could make holdable items project to attachable component…? That could be a great idea!



# SYNCING:
How should we sync the position of attachable entities?  We ideally want to reuse infra from the sync mod… might require some restructuring of bidirectional sync definitions within spatial mod.

Hrmm.. on second thought, it may be best to sync positions manually… kinda like how usables activations are synced manually. It just gives us a lot more control over stuff.

We probably want some sort of SSet for attached entities:

```lua
parentEnt.attached = Set({ ent1, ent2, ... })
```

From there, when syncing ent1 position, we can send parentEnt inside the packet too