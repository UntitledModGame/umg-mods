

# THINKING TIME!


Idea: Have a component:
```lua
clickToOpenUI = {
    distance = 100, -- interacts from this distance away
}
```




## TODO LIST:

- Do planning for opening/closing UIs.
    - We want UIs to automatically close if there is no control-entity with `permission` to open then.
    
- Planning for togglable UI for player-entities.
    - How do we do opening of UIs that are bound to player entities?

- Create `clickToOpenUI` component

- Create `toggleUI` functionality, 
allowing the user to click a button to open/close ALL possible UIs.





### OPENING / CLOSING UIs:
How to open:
`clickToOpenUI` component. EZ!

How to automatically close:
This... is kindof awkward. Because I think it's gonna have to be an 
`O(m*n)` lookup, where `m=#players`, and `n=number of open UIs`.
-->
We *could* keep track of the player-entity that opened the UI in
the first place, but thats bad and fragile.
----->
Practical solution:  
Only check for closing inventories every 60 frames, or something.
hehe.



### pressToOpenUI UI for players
It's really amazing UX to be able to press a button, and instantly
open all UIs that you are in control of.
EG. player backpack.
(Similar to how inventories used to be implemented!)

What would be the cleanest way to do this in UMG?
Honestly, it'd be super clean to just have a component:
```lua
.pressToOpenUI
```



