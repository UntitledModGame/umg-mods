

local SlotElement = require("client.SlotElement")

local gridSlots = require("shared.gridSlots")




local GridInventory = ui.Element("items:GridInventory")




local DEFAULT_SLOT_PADDING = 0.0625
local DEFAULT_BORDER_PADDING = 0.05


function GridInventory:init(args)
    self.slotElements = objects.Array()

    self.width = args.width
    self.height = args.height

    self.borderPadding = args.borderPadding or DEFAULT_BORDER_PADDING
    self.slotPadding = args.slotPadding or DEFAULT_SLOT_PADDING

    for slot=1, self.width * self.height do
        local slotElem = SlotElement({
            slot = slot,
            inventory = args.inventory
        })
        self:addChild(slotElem)
        self.slotElements:add(slotElem)
    end
end




local function getSlotRegion(self, slotRegion, slot)
    local x,y = gridSlots.slotToCoords(slot)
    assert(x < self.width and y < self.height, "coords supposed to be 0 indexed?")
    local dw = slotRegion.w / self.width
    local dh = slotRegion.h / self.height

    return ui.Region(
        x*dw,
        y*dh,
        dw, dh
    )
end



local function getInventoryName(self)
    --[[
        TODO: draw name of inventory
    ]]
    local ent = self.owner
    return (ent.inventoryName or self.name)
end




function GridInventory:onRender(x,y,w,h)
    local region = ui.Region(x,y,w,h)
    ui.helper.rectangle(self, region:get())
    ui.helper.outline(self, region:get())

    local title, body = region:splitVertical(0.1, 0.9)
    if title then
        -- TODO: draw title here.

        -- we also should be drawing a `close` 
        -- button within the title region.
    end
    ui.helper.outline(self, body:pad(0.01):get())

    local slotRegion = body:pad(self.borderPadding)
    for slot, slotElem in ipairs(self.slotElements) do
        assert(slot == slotElem:getSlot(), "???")
        local r = getSlotRegion(self, slotRegion, slot)
        slotElem:render(r
            :pad(self.slotPadding)
            :get()
        )
    end
end



return GridInventory

