


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




## ACTIONS:
Actions are a pretty good idea...
But I really don't like the dual-nature of them.

For example, this is really bad:
```lua
lp.activate(ent)
lp.actions.activate(ent)
```
^^^ We should NEVER have stuff like this.

```lua
lp.buffer(ppos, function()
    local item = lp.getItem(ppos)
    if item then
        increaseSellPrice(item)
        lp.sellItem(item)
    end
end)
```


## IDEA: Lets plan the API **BEFORE** we decide on the buffering behaviour.
See `item_API.md`



