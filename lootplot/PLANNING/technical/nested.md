

# SUPER IMPORTANT:::
We need to make sure that *augments* (and stuff) can apply 
the same effects as item/slot entities.  

## IDEA:  
`.nested` component.  
This component would basically provide a way to "nest" stuff, such as listeners, activators, property-mutators, etc etc.

```lua
ent.nested = {ent1, ent2}
```

This would mean that augments would just be regular-entities...
which is really clean and elegant.


