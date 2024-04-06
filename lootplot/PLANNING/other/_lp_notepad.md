


## SLOTS:
Do we need these functions...?
Hmm... maybe we should keep some of them..?

But I also think that some of them should be global helpers instead
```lua
function slots.canAdd()
function slots.tryAdd()
function slots.canRemove()
```

OK.
lets think: How would we implement a slot that can only take {trait} items?

Definitely should be emitting a question.
I guess the question is:
WHERE should we emit said question from?
This is what this file would be great for.

Do we want to allow blocking of removal..?
I feel like thats a bit weird... idk

Are there any valid use-cases for blocking item-removal?
(Not really, I feel like!)




# `SYSTEM PLANNING:`
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
- `localProperty` system; allows modification of properties of entities
    - (also need a qbus for pricing)

### increase power of any slots in range by 1
- `localProperty` system



# OK: Final plan:
property system:
    - globalProperty modification (ent -> plot)
    - localProperty modification (ent -> ent)

listener system:
    - globalListener (plot-event)
    - localListener (ent-event; only works within range)
        (internal tracking for efficiency?)

