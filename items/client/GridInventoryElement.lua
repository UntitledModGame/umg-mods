

local SlotElement = require("client.SlotElement")

local gridSlots = require("shared.gridSlots")




local GridInventory = ui.Element("items:GridInventory")




local DEFAULT_SLOT_PADDING = 0.0625
local DEFAULT_BORDER_PADDING = 0.05



local ARGS = {"inventory", "rows", "columns"}


function GridInventory:init(args)
    objects.assertKeys(args, ARGS)
    self.slotElements = objects.Array()

    -- This is the width/height of the INVENTORY slots
    self.columns = args.columns
    self.rows = args.rows

    self.inventory = args.inventory

    self.borderPadding = args.borderPadding or DEFAULT_BORDER_PADDING
    self.slotPadding = args.slotPadding or DEFAULT_SLOT_PADDING

    local size = self.columns * self.rows
    assert(size == self.inventory.size, "width/height needs to match with inventory size!")
    for slot=1, size do
        local slotElem = SlotElement({
            slot = slot,
            inventory = args.inventory
        })
        self:addChild(slotElem)
        self.slotElements:add(slotElem)
    end
end




local function getSlotRegion(self, slotRegion, slot)
    local x,y = gridSlots.slotToCoords(slot, self.columns, self.rows)
    assert(x < self.columns and y < self.rows, "coords supposed to be 0 indexed?")

    local dw = slotRegion.w / self.columns
    local dh = slotRegion.h / self.rows

    local r = ui.Region(
        slotRegion.x + x*dw,
        slotRegion.y + y*dh,
        dw, dh
    )
    local minn = math.min(dw,dh)
    return r
        :shrinkTo(minn,minn)
        :center(r)
        :pad(self.slotPadding)
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
        slotElem:render(r:get())
    end
end



return GridInventory

