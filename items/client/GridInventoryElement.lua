

local SlotElement = require("client.SlotElement")





local GridInventory = ui.Element("items:GridInventory")




local DEFAULT_SLOT_PADDING = 0.0625
local DEFAULT_BORDER_PADDING = 0.05



local ARGS = {"inventory", "width", "height"}


function GridInventory:init(args)
    typecheck.assertKeys(args, ARGS)
    self.slotElements = objects.Array()

    -- This is the width/height of the INVENTORY slots
    self.width = args.width
    self.height = args.height

    -- Grid-object- used ONLY for calculating slot-positions:
    self.gridObj = objects.Grid(self.width, self.height)

    self.inventory = args.inventory

    self.borderPadding = args.borderPadding or DEFAULT_BORDER_PADDING
    self.slotPadding = args.slotPadding or DEFAULT_SLOT_PADDING

    local size = self.width * self.height
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
    local x,y = self.gridObj:indexToCoords(slot)
    if not (x < self.width and y < self.height) then 
        print(x,y, self.width, self.height)
        print(slot)
        error("coords supposed to be 0 indexed?")
    end

    local dw = slotRegion.w / self.width
    local dh = slotRegion.h / self.height

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
    ui.helper.outline(self, region:get())
    region = region:padPixels(self:getOption("lineWidth"))
    ui.helper.outsetRectangle(self, region:get())

    local title, body = region:splitVertical(0.1, 0.9)
    if title then
        -- TODO: draw title here.

        -- we also should be drawing a `close` 
        -- button within the title region.
    end

    local slotRegion = body:pad(self.borderPadding)
    for slot, slotElem in ipairs(self.slotElements) do
        assert(slot == slotElem:getSlot(), "???")
        local r = getSlotRegion(self, slotRegion, slot)
        slotElem:render(r:get())
    end
end



return GridInventory

