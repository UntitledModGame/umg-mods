

--[[

Inventory objects.

Inventory objects can be extended, to create cooler, custom inventories.
You can also override any part of the rendering, to create custom
inventory backgrounds, custom slots, etc etc.

]]


local SlotHandle = require("shared.SlotHandle")

local Inventory = objects.Class("items_mod:inventory")



local assertNumber = typecheck.assert("number")

local DEFAULT_INVENTORY_COLOUR = {0.8,0.8,0.8}


local DEFAULT_BORDER_WIDTH = 10
local DEFAULT_SLOT_SIZE = 12
local DEFAULT_SLOT_SEPARATION = 2


function Inventory:init(options)
    assert(options.size, "Inventories must have a .size value!")
    self.size = options.size

    self.slotHandles = {--[[
        [slot] -> SlotHandle object
    ]]}

    -- size of inventory slots
    self.slotSize = options.slotSize or DEFAULT_SLOT_SIZE
    -- separation between inventory slots
    self.slotSeparation = options.slotSeparation or DEFAULT_SLOT_SEPARATION
    -- border offset from inventory edge
    self.borderWidth = options.borderWidth or DEFAULT_BORDER_WIDTH

    self.totalSlotSize = self.slotSize + self.slotSeparation

    self.inventory = {}  -- Array where the items are actually stored.

    -- randomize initial draw position, to avoid overlap
    self.draw_x = math.random(0, 100)
    self.draw_y = math.random(0, 100)

    if options.color then
        assert(type(options.color) == "table", "inventory colours must be {R,G,B} tables, with RGB values from 0-1!")
        self.color = options.color
    else
        self.color = DEFAULT_INVENTORY_COLOUR
    end

    self.is_open = false

    self.owner = nil -- The entity that owns this inventory.
    -- Should be set by some system.
end








local function assertItem(itemEnt)
    assert(itemEnt.itemName, "items need an itemName component")
    assert((not itemEnt.description) or type(item_ent.description) == "string", "item entity descriptions must be strings")
    assert((not itemEnt.stackSize) or type(item_ent.stackSize) == "number", "item entity stackSize must be a number")
    assert((not itemEnt.maxStackSize) or type(item_ent.maxStackSize) == "number", "item entity maxStackSize must be a number")
end



function Inventory:onItemMoved(item, slot)
    -- Override this, if you want
end



local function signalMoveToSlot(self, slot, itemEnt)
    -- calls appropriate callbacks for item addition
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemAdded(itemEnt, slot)
    end
    self:onItemMoved(itemEnt, slot)
    umg.call("items:itemMoved", self.owner, itemEnt, slot)
end



function Inventory:onItemStackSizeChange(item, stackChange, slot)
    -- Override this, if you want
end

local function signalStackSizeChange(self, slot, stackChange)
    -- called when a stackSize of an item changes
    local item = self:get(slot)
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemAdded(item, slot)
    end
    self:onItemStackSizeChange(item, stackChange, slot)
    umg.call("items:stackSizeChange", self.owner, item, stackChange, slot)
end



function Inventory:onItemRemoved(item, slot)
    -- Override this, if you want
end


local function signalRemoveFromSlot(self, slot, itemEnt)
    -- calls appropriate callbacks for item removal
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemRemoved(itemEnt, slot)
    end
    self:onItemRemoved(itemEnt, slot)
    umg.call("items:itemRemoved", self.owner, itemEnt, slot)
end





local function put(self, slot, itemEnt)
    --[[
        Directly puts an item into a slot
    ]]
    assert(server, "Can only be called on server")
    assertNumber(slot)

    -- If `itemEnt` is nil, then it removes the item from inventory.
    self.inventory[slot] = itemEnt
    if itemEnt then
        assertItem(itemEnt)
        self.inventory[slot] = itemEnt
        server.broadcast("items:setInventorySlot", self.owner, slot, itemEnt)
    else
        self.inventory[slot] = nil
        server.broadcast("items:clearInventorySlot", self.owner, slot)
    end
end



function Inventory:count(item_or_itemName)
    local itemName
    if (type(item_or_itemName) == "table") and item_or_itemName.itemName then
        itemName = item_or_itemName.itemName
    else
        assert(type(item_or_itemName) == "string", "Inventory:count(itemName) expects a string")
        itemName = item_or_itemName -- should be type `str`
    end

    local count = 0
    for slot=1, self.size do
        local check_item = self:get(slot)
        if check_item then
            -- if its nil, there is no item there.
            if itemName == check_item.itemName then
                count = count + check_item.stackSize
            end
        end
    end
    return count
end


function Inventory:contains(item_or_itemName)
    for slot=1, self.size do
        local check_item = self:get(slot)
        if check_item then
            -- if its nil, there is no item there.
            if item_or_itemName == check_item.itemName or item_or_itemName == check_item then
                return true, slot
            end
        end
    end
    return false
end



function Inventory:getEmptySlot()
    -- Returns the slot of an empty inventory slot
    for slot=1, self.size do
        if not self:get(slot) then
            return slot
        end
    end
end





local function canAddToSlot(self, slot, item)
    local slotHandle = self:getSlotHandle(slot)

    if slotHandle then
        local ok = slotHandle:canAddItem(item, slot)
        if not ok then return false end
    end

    local invEnt = self.owner
    local isBlocked = umg.ask("items:isItemAdditionBlocked", item, invEnt, slot)
    return not isBlocked
end



local function canCombineStacks(item1, item2, count)
    --[[
        Returns true if item1 can be combined into item2.
        false otherwise.
    ]]
    -- `count` is the number of items that we want to add. (defaults to the full stackSize of item)
    count = (count or item1.stackSize) or 1

    if item1.itemName ~= item2.itemName then
        return false -- deny; items can't be combined.
    end

    local remainingStackSize = (item1.maxStackSize or 1) - count
    if (remainingStackSize < count) then
        return false -- not enough stack space to combine
    end

    return true -- ok
end


local canAddToSlotTc = typecheck.assert("number", "entity", "number?")

-- returns `true` if we can add `count` stacks of item to `slot`,
-- false otherwise.
function Inventory:canAddToSlot(slot, item, count)
    canAddToSlotTc(slot, item, count)
    -- `count` is the number of items that we want to add. (defaults to the full stackSize of item)
    count = (count or item.stackSize) or 1

    local itemEnt = self:get(slot)
    if itemEnt then
        if not canCombineStacks(item, itemEnt, count) then
            return false -- can't combine stacks!
        end
    end

    if not canAddToSlot(self, slot, item) then
        return false -- blocked
    end

    return true -- Yup, we can add!
end


function Inventory:tryAddToSlot(slot, item, count)
    canAddToSlotTc(slot, item, count)
    if self:canAddToSlot(slot, item, count) then
        self:add(slot, item)
        return true
    end
    return false
end



function Inventory:canRemoveFromSlot(slot)
    --[[
        returns true if we can remove item from (slot),
        returns true if there is no item,
        returns false if item removal is blocked.
    ]]
    assertNumber(slot)
    local item = self:get(slot)
    if not item then
        return true -- no item, so I guess we can remove
    end

    local invEnt = self.owner
    local isBlocked = umg.ask("items:isItemRemovalBlocked", item, invEnt, slot)
    return not isBlocked
end





--[[
    Finds an inventory slot that will fit `item`

    count is the number of items to take from the stack. (default = item.stackSize)
]]
function Inventory:findAvailableSlot(item, count)
    for slot=1, self.size do
        if self:canAddToSlot(slot, item, count) then
            -- slot is available!
            return slot
        end
    end
    return false -- can't add
end




function Inventory:find(item_or_itemName)
    --[[
        finds the slot of an item, given an item (or itemName)
    ]]
    for slot=1, self.size do
        local item = self:get(slot)
        if item and item == item_or_itemName or item.itemName == item_or_itemName then
            -- found! return slot.
            return slot
        end
    end
    return nil -- no slot found
end







local moveStackCountTc = typecheck.assert("table", "number", "table?")

local function getMoveStackCount(item, count, targetItem)
    moveStackCountTc(item, count, targetItem)
    --[[
        gets how many items can be moved from item to targetItem
    ]]
    local stackSize = item.stackSize or 1
    count = math.max(0, count or stackSize)

    if targetItem then
        local targSS = targetItem.stackSize or 1
        local targMaxSS = targetItem.maxStackSize or 1
        local stacksLeft = targMaxSS - targSS
        local maxx = item.maxStackSize or 1
        return math.min(math.min(maxx, count), stacksLeft)
    else
        local maxx = item.maxStackSize or 1
        return math.min(maxx, count)
    end
end


local function moveIntoTakenSlot(self, slot, otherInv, otherSlot, count)
    local targ = otherInv:get(otherSlot)
    local item = self:get(slot)
    count = getMoveStackCount(item, count, targ)

    if not self:canRemoveFromSlot(slot) then
        return false -- we can't remove items from this slot
    end

    local newStackSize = item.stackSize - count
    if newStackSize <= 0 then
        -- delete src item, since all it's stacks are gone
        self:remove(slot)
        item:delete()
    else
        -- else, we reduce the src item stacks
        self:setStackSize(slot, newStackSize)
    end

    -- add stacks to the target item 
    local new = targ.stackSize + count
    otherInv:setStackSize(otherSlot, new)
    return true -- success.
end



local function moveIntoEmptySlot(self, slot, otherInv, otherSlot, count)
    local item = self:get(slot)
    count = getMoveStackCount(item, count)
    if count <= 0 then return
        false -- failure, no space
    end

    if not self:canRemoveFromSlot(slot) then
        return false -- failure, denied
    end

    if count < item.stackSize then
        -- then we are only moving part of the stack; so we must create a copy
        local newItem = item:clone()
        newItem.stackSize = count 
        -- We don't call :setStackSize above, because newItem has just been cloned
        self:setStackSize(slot, item.stackSize - count)
        otherInv:add(otherSlot, newItem)
    else
        -- we are moving the whole item
        self:remove(slot)
        otherInv:add(otherSlot, item)
    end
    return true -- success
end



local moveTc = typecheck.assert("number", "number", "table", "number?")

function Inventory:tryMove(slot, otherInv, count)
    --[[
        attempts to move the item at slot in `self`
        into otherInv.

        Returns true on success, false on failure.
    ]]
    moveTc(slot, otherInv, count)
    local item = self:get(slot)
    local otherSlot = otherInv:findAvailableSlot(item, count)
    if otherSlot then
        return self:tryMoveToSlot(slot, otherInv, otherSlot, count)
    end
    return false
end



local moveSwapTc = typecheck.assert("number", "table", "number", "number")

function Inventory:tryMoveToSlot(slot, otherInv, otherSlot, count)
    --[[
        moves an item from one inventory to another.
        Can also specify the `stackSize` argument to only send part of a stack.
    ]]
    assert(server, "only available on server")
    moveSwapTc(slot, otherInv, otherSlot, count)

    local item = self:get(slot)
    local stackSize = item.stackSize or 1
    count = math.min(count or stackSize, stackSize)

    if not otherInv:canAddToSlot(otherSlot, item, count) then
        return false -- failed
    end
    
    local targ = otherInv:get(otherSlot)
    if targ then
        return moveIntoTakenSlot(self, slot, otherInv, otherSlot, count)
    else
        return moveIntoEmptySlot(self, slot, otherInv, otherSlot, count)
    end
end




local trySwapTc = typecheck.assert("number", "table", "number")

function Inventory:trySwap(slot, otherInv, otherSlot)
    --[[
        swaps two items in inventories.
        
        Returns true on success, false on failure.
    ]]
    assert(server, "only available on server")
    trySwapTc(slot, otherInv, otherSlot)
    local item = self:get(slot)
    local otherItem = otherInv:get(otherSlot)

    if item == otherItem then
        return -- we aren't moving anything!
    end

    local removeOk = self:canRemoveFromSlot(slot) and otherInv:canRemoveFromSlot(otherSlot)
    if not removeOk then
        return false -- we can't remove one of the items, so we can't swap
    end

    -- NOTE: This feels kinda dumb removing the items here,
    -- because the operation isn't guaranteed to succeed yet...
    self:remove(slot)
    otherInv:remove(otherSlot)

    -- if there is no item, adding it to the other slot is ok. (explains the first OR condition)
    local addOk1 = (not otherItem) or self:canAddToSlot(slot, otherItem)
    local addOk2 = (not item) or otherInv:canAddToSlot(otherSlot, item)
    local addOk = addOk1 and addOk2

    if addOk then
        self:add(slot, otherItem)
        otherInv:add(otherSlot, item)
        return true -- success!
    else
        -- uh oh! reset to original slots. 
        -- (TODO: this is dumb, because this will emit itemMoved events :/ )
        self:add(slot, otherItem)
        otherInv:add(otherSlot, item)
        return false -- failure; operation was reversed.
    end
end



local addTc = typecheck.assert("entity", "number")
function Inventory:add(item, slot)
    -- Directly adds an item to an inventory.
    -- If the item is combined as a stack, the old item is deleted.

    -- WARNING: THIS METHOD IS QUITE DANGEROUS TO CALL!!!
    -- `item` must NOT be in any other inventory!
    -- If item is in another inv, the item-entity will be duplicated across BOTH inventories!!!
    addTc(slot, item)
    local itm = self:get(slot)
    if itm then
        -- increment stackSize:
        assert(canCombineStacks(item, itm), "can't combine stacks!")
        local stackSize = (itm.stackSize or 1) + (item.stackSize or 1)
        self:setStackSize(slot, stackSize)
        item:delete()
        -- TODO ^^^ maybe we should set the stackSize to 0 instead of deleting?
        -- that way, another system will handle the deletion of item entities with 0 stack size... could be cleaner
    else
        -- only signal an add to slot if the slot was empty
        signalMoveToSlot(self, slot, item)
        put(self, slot, item)
    end
end


function Inventory:remove(slot)
    -- WARNING: Somewhat unsafe to call!!!
    -- Directly removes an item from a slot in an inventory.
    -- This is kinda like deleting the item.
    local item = self:get(slot)
    if item then
        signalRemoveFromSlot(self, slot, item)
    end
    put(self, slot, nil)
end


function Inventory:setStackSize(slot, stackSize)
    -- WARNING: Somewhat unsafe to call!!!
    -- Directly sets a stack size for an item.
    -- Be careful when using!
    local item = self:get(slot)
    if not item then
        return -- wot wot??? lmao
    end
    local change = stackSize - item.stackSize
    if change == 0 then
        return -- no change.
    end

    item.stackSize = stackSize
    signalStackSizeChange(self, slot, change)
end






function Inventory:get(slot)
    assertNumber(slot)
    local e = self.inventory[slot]
    if umg.exists(e) then
        return e
    end
end





function Inventory:getSlotHandle(slot)
    return self.slotHandles[slot]
end


function Inventory:setSlotHandle(slot, slotHandle)
    --[[
        sets a slot handle at `slot` to slotHandle
    ]]
    assertNumber(slot)
    if not SlotHandle.isInstance(slotHandle) then
        error("Not an instance of SlotHandle: " .. tostring(slotHandle))
    end

    slotHandle:setSlotPosition(slot)
    self.slotHandles[slot] = slotHandle
end






if client then


client.on("items:setInventorySlot", function(ent, slot, itemEnt)
    local inventory = ent.inventory
    inventory[slot] = itemEnt
end)

client.on("items:clearInventorySlot", function(ent, slot)
    ent.inventory[slot] = nil
end)


end





return Inventory