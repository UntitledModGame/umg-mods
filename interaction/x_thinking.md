

# THINKING TIME!


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

## IDEA:
Don't only have `clickToInteract`.
ALSO have `clickToOpenUI`.

^^^ But... can we extend this with other mods?
I think we can, right?




## TODO LIST:

Create `clickToOpenUI` 



