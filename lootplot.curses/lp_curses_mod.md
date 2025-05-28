

## Lootplot curses mod:

Provides an API for creating curse-items and curse-slots.  

(aka items/slots with negative-effects, that you want to get rid of)

========================================

## CURSE SPAWNING:


`canItemFloat`:  
A lot of curses have been defined as FLOATY.  
-->  
How about instead of defining them floaty, we GIVE them floaty if they are spawned midair?
Otherwise, they aren't floaty.


IDEA: Have hardcoded "pools" of curses:


- Starter-Curses. Should only be spawned in at start
- Normal-Curses; Can be spawned in randomly


Curse spawn types {
    - Within(X): Must be spawned within X units of player's basic-slots
        (if this isn't specified, defaults to Within(2))
    - Above: Must be spawned ABOVE y=0
    - Below: Must be spawned BELOW y=0
    - Land: Must be spawned on land
    - Air: Must be spawned midair
    - Snap: Must be spawned next to a player's item
    - Shop: Must be spawned next to shop
}

^^^^ Spawn-types should be defined inside of `lp.curses` mod

