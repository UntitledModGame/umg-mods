

# Flag components:

BIG QUESTION TIME:

We have a *bit* of an issue.

`ui` mod kinda seems to be doing 2 things at once:
- Allows entities to be opened; via `ui` component
    ^^^ This is great, I'm happy with this.
- Provides an API for checking accessibility of entities. `accessible`? 

The 2nd one is a bit eeeehhh, weird.
Because it's kinda unclear on what it's actual purpose is.

Its supposed purpose was to check whether "UIs can be opened",
but its kinda leaking to other parts of the codebase...




