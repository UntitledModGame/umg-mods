
--[[
    
An "SlotHandle" is an object representing an inventory slot.

It's useful when we want slots to have complex behaviour.
For example, an armor slot.
Or, a slot that allows an entity to hold an item.



]]


local SlotHandle = objects.Class("items:SlotHandle")
--[[
    SlotHandle on it's own is abstract.
    It doesn't really do anything.
]]


local initTc = typecheck.assert("table")

function SlotHandle:init(inventory)
    initTc(inventory)
    self.inventory = inventory
end



local numberTc = typecheck.assert("number")

function SlotHandle:setSlotPosition(slot)
    numberTc(slot)
    self.slot = slot
end



--[[
    TO BE OVERRIDDEN:
]]
function SlotHandle:onItemAdded(item)
end
function SlotHandle:onItemRemoved(item)
end

function SlotHandle:canAddItem(item)
    -- returns true/false,
    -- whether the item can be added to this slot
    return true -- (default)
end
function SlotHandle:canRemoveItem(item)
    -- returns true/false,
    -- whether the item can be removed from this slot
    return true -- (default)
end

function SlotHandle:preDraw(drawX, drawY, drawWidth, drawHeight)
    -- to be overridden.
    -- called before this slot should be drawn.
end
function SlotHandle:postDraw(drawX, drawY, drawWidth, drawHeight)
    -- to be overridden.
    -- called after this slot should be drawn.
end
-- These two are useful for cool, custom slot vfx!


function SlotHandle:getInventory()
    return self.inventory
end

function SlotHandle:getOwner()
    return self.inventory.owner
end


function SlotHandle:addItem(item)
    self:onItemAdded(item)
end

function SlotHandle:removeItem(item)
    self:onItemRemoved(item)
end


local function getItem(self)
    local inv = self.inventory
    return inv:get(self.slot)
end

function SlotHandle:hasItem()
    local item = getItem(self)
    return umg.exists(item)
end


function SlotHandle:get()
    local item = getItem(self)
    if not umg.exists(item) then
        umg.melt("Slot item didn't exist!")
    end
    return item
end



return SlotHandle
