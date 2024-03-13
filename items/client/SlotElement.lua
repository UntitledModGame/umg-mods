
local slotService = require("client.slotService")
local tooltipService = require("client.tooltipService")


local SlotElement = ui.Element("items:SlotElement")


local KEYS = {"slot", "inventory"}

function SlotElement:init(args)
    typecheck.assertKeys(args, KEYS)
    self.slot = args.slot
    self.inventory = args.inventory

    -- blank image for now
    self.image = ui.elements.Image({})
    self:addChild(self.image)
    self.hasImage = false
    self:setOption("backgroundColor", {0.76,0.76,0.76})
end



local function getItemIcon(itemEnt)
    return itemEnt.itemIcon or itemEnt.image
end



function SlotElement:getItem()
    local itemEnt = self.inventory:get(self.slot)
    if umg.exists(itemEnt) then
        return itemEnt
    end
end




local function updateImage(self)
    local ent = self:getItem()
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
end



function SlotElement:renderForeground(x,y,w,h)
end



function SlotElement:renderBackground(x,y,w,h)
    ui.helper.insetRectangle(self, x,y,w,h)
end




local function updateText(self, stackSize)
    if not self.text then
        self.text = ui.elements.Text({
            outline = 1,
        })
        self:addChild(self.text)
    end
    self.text:setText(tostring(stackSize))
end


function SlotElement:renderStackSize(x,y,w,h)
    local item = self:getItem()
    local stackSize = item.stackSize or 1
    if stackSize > 1 then
        updateText(self, stackSize)
        self.text:render(x,y,w,h)
    end
end



function SlotElement:onRender(x,y,w,h)
    self:renderBackground(x,y,w,h)
    local item = self:getItem()
    if item then
        self:renderItem(x,y,w,h)
        self:renderStackSize(x,y,w,h)

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



function SlotElement:onClickPrimary()
    slotService.interactPrimary(self)
end

function SlotElement:onClickSecondary()
    slotService.interactSecondary(self)
end


function SlotElement:onStartHover()
    tooltipService.startHover(self)
end

function SlotElement:onEndHover()
    tooltipService.endHover(self)
end




return SlotElement

