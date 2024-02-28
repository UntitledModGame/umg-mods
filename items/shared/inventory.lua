

--[[

Inventory objects.

Inventory objects can be extended, to create cooler, custom inventories.
You can also override any part of the rendering, to create custom
inventory backgrounds, custom slots, etc etc.

]]


local SlotHandle = require("shared.SlotHandle")

local Inventory = objects.Class("items_mod:inventory")

local h = require("shared.helper")



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
    assert((not itemEnt.description) or type(itemEnt.description) == "string", "item entity descriptions must be strings")
    assert((not itemEnt.stackSize) or type(itemEnt.stackSize) == "number", "item entity stackSize must be a number")
    assert((not itemEnt.maxStackSize) or type(itemEnt.maxStackSize) == "number", "item entity maxStackSize must be a number")
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






local function signalStackSizeChange(self, item, slot, stackSize)
    -- called when a stackSize of an item changes
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemAdded(item, slot)
    end
    self:onItemStackSizeChange(item, slot, stackSize)
    umg.call("items:stackSizeChange", self.owner, item, slot, stackSize)
end


local function setStackSize(self, slot, stackSize)
    local item = self:get(slot)
    if item then
        if item.stackSize == stackSize then
            return -- not changing anything!
        end
        signalStackSizeChange(self, item, slot, stackSize)
        item.stackSize = stackSize
    end
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



local function assertServer()
    if not server then
        error("Can only be called on server", 2)
    end
end


local function put(self, slot, itemEnt)
    --[[
        Directly puts an item into a slot
    ]]
    assertServer()
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




local function remove(self, slot)
    local item = self:get(slot)
    if not item then
        return
    end
    signalRemoveFromSlot(self, slot, item)
    put(self, slot, nil)
end





local addTc = typecheck.assert("table", "entity", "number")
local function add(self, slot, item)
    -- Directly adds `count` items to this inventory.
    -- If the item is combined as a stack, the old item is deleted.
    addTc(self, item, slot)
    local itm = self:get(slot)
    if itm then
        -- increment stackSize:
        assert(h.canCombineStacks(item, itm), "can't combine stacks!")
        local stackSize = (itm.stackSize or 1) + (item.stackSize or 1)
        setStackSize(self, slot, stackSize)
        item:delete()
        -- TODO ^^^ maybe we should set the stackSize to 0 instead of deleting?
        -- that way, another system will handle the deletion of item entities with 0 stack size... could be cleaner
    else
        -- only signal an add to slot if the slot was empty
        signalMoveToSlot(self, slot, item)
        put(self, slot, item)
    end
end




function Inventory:isValidSlot(slot)
    -- checks if `slot` is a valid slot.
    -- Useful when we are using untrusted data from client-side.
    if math.floor(slot) ~= slot then
        return false
    end
    return (slot >= 1) and (slot <= self.size)
end




local function getItemType(item_or_itemType)
    if umg.exists(item_or_itemType) then
        return item_or_itemType:type()
    else
        local itemType = item_or_itemType
        if type(itemType) ~= "string" then
            error("Expects an entity-type of an item (string), or an item-entity!", 2)
        end
        return itemType
    end
end


function Inventory:count(item_or_itemType)
    local itemType = getItemType(item_or_itemType)
    local count = 0
    for slot=1, self.size do
        local itemEnt = self:get(slot)
        if itemEnt then
            -- if its nil, there is no item there.
            if itemType == itemEnt:type() then
                count = count + itemEnt.stackSize
            end
        end
    end
    return count
end


function Inventory:contains(item_or_itemType)
    local itemType = getItemType(item_or_itemType)
    for slot=1, self.size do
        local itemEnt = self:get(slot)
        if itemEnt then
            -- if its nil, there is no item there.
            if itemType == itemEnt:type() then
                return slot
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



local canAddToSlotTc = typecheck.assert("number", "entity", "number?")

-- returns `true` if we can add `count` stacks of item to `slot`,
-- false otherwise.
function Inventory:canAddToSlot(slot, item, count)
    canAddToSlotTc(slot, item, count)
    -- `count` is the number of items that we want to add. (defaults to the full stackSize of item)
    count = (count or item.stackSize) or 1

    local itemEnt = self:get(slot)
    if itemEnt then
        if not h.canCombineStacks(item, itemEnt, count) then
            return false -- can't combine stacks!
        end
    end

    if not canAddToSlot(self, slot, item) then
        return false -- blocked
    end

    return true -- Yup, we can add!
end


function Inventory:tryAddItem(slot, item, count)
    canAddToSlotTc(slot, item, count)
    if self:canAddToSlot(slot, item, count) then
        add(self, slot, item)
        return true
    end
    return false
end



function Inventory:canRemoveFromSlot(slot, count)
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
    count = count or (item.stackSize or 1)

    local invEnt = self.owner
    local isBlocked = umg.ask("items:isItemRemovalBlocked", item, invEnt, slot, count)
    return not isBlocked
end


function Inventory:tryRemoveItem(slot, count)
    if self:canRemoveFromSlot(slot, count) then
        remove(self, slot)
        return true
    end
    return false
end




--[[
    Finds an inventory slot that will fit `item`

    count is the number of items to take from the stack. (default = item.stackSize)
]]
function Inventory:findSlotForItem(item, count)
    for slot=1, self.size do
        if self:canAddToSlot(slot, item, count) then
            -- slot is available!
            return slot
        end
    end
    return false -- can't add
end




function Inventory:find(item_or_itemType)
    --[[
        finds the slot of an item, given an item (or itemName)
    ]]
    local itemType = getItemType(item_or_itemType)
    for slot=1, self.size do
        local item = self:get(slot)
        if item and itemType == item:type() then
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
        remove(self, slot)
        item:delete()
    else
        -- else, we reduce the src item stacks:
        setStackSize(self, slot, newStackSize)
    end

    -- add stacks to the target item 
    setStackSize(otherInv, otherSlot, targ.stackSize + count)
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
        -- We don't call `setStackSize` above, because newItem has just been cloned,
        -- And doesn't exist within the ECS yet!
        setStackSize(self, slot, item.stackSize - count)
        add(otherInv, otherSlot, newItem)
    else
        -- we are moving the whole item
        remove(self, slot)
        add(otherInv, otherSlot, item)
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
    local otherSlot = otherInv:findSlotForItem(item, count)
    if otherSlot then
        return self:tryMoveToSlot(slot, otherInv, otherSlot, count)
    end
    return false
end



local moveSwapTc = typecheck.assert("number", "table", "number", "number")

function Inventory:tryMoveToSlot(slot, otherInv, otherSlot, count)
    --[[
        moves an item from one inventory to another.
        Can also specify the `count` argument to only send part of a stack.
    ]]
    assertServer()
    moveSwapTc(slot, otherInv, otherSlot, count)

    local item = self:get(slot)
    local stackSize = item.stackSize or 1
    count = math.min(count or stackSize, stackSize)

    if not otherInv:canAddToSlot(otherSlot, item, count) then
        return false
    end
    if not self:canRemoveFromSlot(slot, count) then
        return false
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
    assertServer()
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
    remove(self, slot)
    remove(otherInv, otherSlot)

    -- if there is no item, adding it to the other slot is ok. (explains the first OR condition)
    local addOk1 = (not otherItem) or self:canAddToSlot(slot, otherItem)
    local addOk2 = (not item) or otherInv:canAddToSlot(otherSlot, item)
    local addOk = addOk1 and addOk2

    if addOk then
        add(self, slot, otherItem)
        add(otherInv, otherSlot, item)
        return true -- success!
    else
        -- uh oh! reset to original slots. 
        -- (TODO: this is dumb, because this will emit itemMoved events :/ )
        add(self, slot, otherItem)
        add(otherInv, otherSlot, item)
        return false -- failure; operation was reversed.
    end
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







function Inventory:canBeAccessedBy(actorEnt)
    return permissions.entityHasPermission(actorEnt, self.owner)
end



local canAddItemTc = typecheck.assert("entity", "entity", "number")
function Inventory:itemCanBeAddedBy(actorEnt, itemToBeAdded, slot)
     -- whether the actorEnt has the authority to add
    -- `item` to the slot (slot)
    canAddItemTc(actorEnt, itemToBeAdded, slot)
    local isBlocked = umg.ask("items:isItemAdditionBlockedForActorEntity", actorEnt, self.owner, itemToBeAdded, slot)
    return not isBlocked
end


local canRemoveItemTc = typecheck.assert("entity", "number")
function Inventory:itemCanBeRemovedBy(actorEnt, slot)
    -- whether the actorEnt has the authority to remove the
    -- item at slot
    canRemoveItemTc(actorEnt, slot)
    local isBlocked = umg.ask("items:isItemRemovalBlockedForActorEntity", actorEnt, self.owner, slot)
    return not isBlocked
end











if client then


client.on("items:setInventorySlot", function(ent, slot, itemEnt)
    local inventory = ent.inventory
    inventory[slot] = itemEnt
end)

client.on("items:clearInventorySlot", function(ent, slot)
    --[[
        WARNING:::
        This is an EXTREMELY LOW LEVEL OPERATION.
        N-E-V-E-R EVERR DO THIS SHIT IN NORMAL CODE!!!
        Stuff WILL break.
        Inventory system integrity will be damaged irreparibly,
        And the world may be corrupted *forever*.

        If you want to remove an item from an inventory, use
        `inventory:tryRemove()` instead.
    ]]
    ent.inventory[slot] = nil
end)


end





return Inventory
