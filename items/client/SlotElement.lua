
local slotService = require("client.slotService")
local tooltipService = require("client.tooltipService")


local SlotElement = ui.Element("items:SlotElement")


local KEYS = {"slot", "inventory"}

function SlotElement:init(args)
    objects.assertKeys(args, KEYS)
    self.slot = args.slot
    self.inventory = args.inventory

    -- blank image for now
    self.image = ui.elements.Image({})
    self.hasImage = false
end



local function getItemIcon(itemEnt)
    return itemEnt.itemIcon or itemEnt.image
end



local function getItem(self)
    local itemEnt = self.inventory:get(self.slot)
    if umg.exists(itemEnt) then
        return itemEnt
    end
end




local function updateImage(self)
    local ent = getItem(self)
    if ent then
        local img = getItemIcon(ent)
        self.hasImage = true
        self.image:setImage(img)
    else
        self.hasImage = false
    end
end


function SlotElement:renderItem(x,y,w,h)
    updateImage(self)

    if self.hasImage then
        self.image:render(x,y,w,h)
    end

    local item = getItem(self)
    local stackSize = item.stackSize or 1
    if stackSize > 1 then
        -- TODO: render stack number here
        -- renderStackNumber(self)
    end
end



function SlotElement:renderForeground(x,y,w,h)
end



function SlotElement:renderBackground(x,y,w,h)
    ui.helper.insetRectangle(self, x,y,w,h)
end



function SlotElement:onRender(x,y,w,h)
    self:renderBackground(x,y,w,h)
    if getItem(self) then
        self:renderItem(x,y,w,h)
    end
    self:renderForeground(x,y,w,h)
end



function SlotElement:getInventory()
    -- the actual Inventory object
    return self.inventory
end

function SlotElement:getSlot()
    -- the slot number; aka index in invnetory array
    return self.slot
end



function SlotElement:onMousePress(mx, my, button)
    slotService.interact(self, button)
end


function SlotElement:onStartHover()
    tooltipService.startHover(self)
end

function SlotElement:onEndHover()
    tooltipService.endHover(self)
end




return SlotElement

