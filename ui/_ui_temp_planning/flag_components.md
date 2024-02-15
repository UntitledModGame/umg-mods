

# Flag components:

BIG QUESTION TIME:

We have a *bit* of an issue.

`ui` mod kinda seems to be doing 2 things at once:
- Allows entities to be opened; via `ui` component
    ^^^ This is great, I'm happy with this.
- Provides an API for checking accessibility of entities. `accessible`? 

The 2nd one is a bit eeeehhh, weird.
Because it's kinda unclear on what it's actual purpose is.

Its proposed purpose was to check whether "UIs can be opened",
but it would be better if it's more generic.
ie:
"Can this client interact with this inventory?"



## IDEA:
Decouple "UIs can be opened" with "interactable" behaviour.
Ie, when calling `ui.open(uiEnt)`, the ui mod doesn't check whether `uiEnt`
is interactable by the clientId.

This reduces coupling, and is quite nice.
Could even create a new mod...?

`interactable` mod?
```lua

-- flag component:
interactable
-- ^^^ denotes that an entity can be interacted with


interaction.canInteract(interactEnt, clientId)


-- args:  (uiEnt, clientId)
question("interactables:canInteract", reducer=OR)
question("interactables:isInteractionBlocked", reducer=OR)

-- args:  (uiEnt, controlEnt)
question("interactables:canInteractWith", reducer=OR)
question("interactables:isInteractionWithBlocked", reducer=OR)



```

