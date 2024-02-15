
## GLUE PLANNING:


```lua

local GridInventory = ui.LUI.Element()

function GridInventory:init(args)
    for x=1, args.width do
        for y=1, args.height do
            SlotElement(self, {
                slot = slotNumber,
                inventory = args.inventory,
            })
        end
    end
end


function GridInventory:onMousePress(button)
    interactionService.interact(button, self.inventory, self.slot)
end

```

How do we glue Slots to inventories?

Remember::: we want custom inventories to be REALLY easy to make!

---

Remember the *golden rule* by Keyslam:
"UI Elements should abstracted away from the logic AS FAR as possible!"

So maybe it makes sense for `SlotElement`s to contain some internal logic...?

```lua
local SlotElement = ui.LUI.Element()

function SlotElement:init(args)
    self.slot = args.slot
    self.inventory = args.inventory
end

function SlotElement:onMousePress(button)
    --[[
        something like this....?
    ]]
    slotService.interactWithSlot(button, self.inventory, self.slot)
end



-- Provide sensible defaults; (can override these methods)
function SlotElement:renderBackground()
    ...
end
function SlotElement:renderItem()
    -- We should DEFINITELY emit an event for this.
    --      ( items:renderItem ...? )
    ...
end
function SlotElement:renderForeground()
    ...
end


function SlotElement:onRender(x,y,w,h)
    self:renderBackground(x,y,w,h)
    self:renderItem(x,y,w,h)
    self:renderForeground(x,y,w,h)
end

```



