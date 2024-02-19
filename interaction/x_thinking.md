

# THINKING TIME!

There's a few things to iron out for the `interaction` mod.

- What exactly is an "interaction"...?
    - How does it relate to `ui` mod?
    - Can other mods extend `interaction`....?? 
        - Like if we add a new type of UI?



## What is an "interaction"?
Lets list all the options:

- interaction mod calls `ui.open` and `execution.useEntity` directly

- interaction mod emits an event. `ui.open` can be called using `umg.on`

- Have a more specialized component that calls it automatically:
```
clickToOpenUI = {
    ...
}
```
`clickToOpenUI` would project to `clickToInteract`

## AMAZING IDEA:
No such thing as `clickToInteract`.
Just have `clickToOpenUI`.



