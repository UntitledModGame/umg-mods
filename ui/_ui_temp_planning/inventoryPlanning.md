

# Inventory planning:
If we were to create `GridInventory`, how would we implement it?


```lua

local GridInventory = ui.LUI()

function GridInventory:init(args)
    local slot = 1
    for x=1, args.width do
        for y=1, args.height do
            Slot(self, {
                inventory = self.inventory
                slot = slot
            })
            slot = slot + 1
        end
    end
end


function GridInventory:onRender()
    ...
end

```


