
local slotService = require("client.slotService")
local tooltipService = require("client.tooltipService")
local helper = require("client.helper")


local SlotElement = ui.Element("items:SlotElement")


local KEYS = {"slot", "inventory"}

function SlotElement:init(args)
    typecheck.assertKeys(args, KEYS)
    self.slot = args.slot
    self.inventory = args.inventory
end


SlotElement.super = SlotElement.init



local function getItemIcon(itemEnt)
    return itemEnt.itemIcon or itemEnt.image
end



function SlotElement:getItem()
    local itemEnt = self.inventory:get(self.slot)
    if umg.exists(itemEnt) then
        return itemEnt
    end
end




function SlotElement:renderItem(x,y,w,h)
    if self.hasImage then
        self.image:render(x,y,w,h)
    end
end



function SlotElement:renderForeground(x,y,w,h)
end



function SlotElement:renderBackground(x,y,w,h)
    helper.insetRectangle(x,y,w,h)
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



function SlotElement:onClick(controlEnum)
    if controlEnum == "input:CLICK_PRIMARY" then
        slotService.interactPrimary(self)
    elseif controlEnum == "input:CLICK_PRIMARY" then
        slotService.interactSecondary(self)
    end
end


function SlotElement:onStartHover()
    tooltipService.startHover(self)
end

function SlotElement:onEndHover()
    tooltipService.endHover(self)
end




return SlotElement

