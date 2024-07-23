

# Property and Listener systems:
We need some assumptionless systems to give a bit more power to entities.

# FINAL PLAN (copy-pasted from below)
property system:
    - plotProperty modification (ent --modifies--> plot property)
    - entityProperty modification (ent --modifies--> otherEnt property)
We ideally want properties to be stateless.
(Or at least, single src of truth)

listener system:
    - plotListener (plot-event)
    - entityListener (ent-event; only works within range)
        (internal tracking for efficiency?)









# SYSTEM PLANNING:
Lets list a highly-diverse set of items, 
and discover what infra we need to implement them. 
(NOTE: We are mainly listing items that would be HARD to create, 
under the current setup.)

### when `touching` item dies: give +10 gold
- `localListener` system, listening to local events, on singular entities

### when plot gains gold, increase power by 1%
- `globalListener` system, listening to global events

### if a rare item is spawned in range, convert it to LEGENDARY.
- localListener system

### while this item is on the plot, increase chance of LEGENDARY items by 50%
- `globalProperty` system
    - (preferably managed by the `Plot` object)
    - MAKE IT EXTENSIVE!!! USE q-buses!!!
    - Idea: maybe a `probabilityWarp` component, that tells the `Plot` to contain the entity within the qbus question...? 
    --> do some thinking.

### discount prices of any slots in range by 50%
- `entityProperty` system; allows modification of properties of entities
    - (also need a qbus for pricing)

### Ice-block: Prevent any items in range from moving
- `entityProperty` system



# OK: Final plan:
property system:
    - plotProperty modification (ent --modifies--> plot property)
    - entityProperty modification (ent --modifies--> otherEnt property)

listener system:
    - plotListener (plot-event)
    - entityListener (ent-event; only works within range)
        (internal tracking for efficiency?)

