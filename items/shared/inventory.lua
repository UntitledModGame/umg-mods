

--[[

Inventory objects.

Inventory objects can be extended, to create cooler, custom inventories.
You can also override any part of the rendering, to create custom
inventory backgrounds, custom slots, etc etc.

]]


local SlotHandle = require("shared.SlotHandle")

local Inventory = objects.Class("items:Inventory")

local h = require("shared.helper")



local assertNumber = typecheck.assert("number")



local OPT = {"entity", "size"}

function Inventory:init(options)
    typecheck.assertKeys(options, OPT)

    self.owner = options.entity
    self.size = options.size

    self.slotHandles = {--[[
        [slot] -> SlotHandle object
    ]]}

    self.inventory = {}  -- Array where the items are actually stored.
end

Inventory.super = Inventory.init








local function assertItem(itemEnt)
    assert((not itemEnt.description) or type(itemEnt.description) == "string", "item entity descriptions must be strings")
    assert((not itemEnt.stackSize) or type(itemEnt.stackSize) == "number", "item entity stackSize must be a number")
    assert((not itemEnt.maxStackSize) or type(itemEnt.maxStackSize) == "number", "item entity maxStackSize must be a number")
end




-- Override these, if you want
function Inventory:onItemAdded(item, slot)
end

function Inventory:onItemRemoved(item, slot)
end








local function signalMoveToSlot(self, slot, itemEnt)
    -- calls appropriate callbacks for item addition
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemAdded(itemEnt, slot)
    end
    self:onItemAdded(itemEnt, slot)
    umg.call("items:itemAdded", self.owner, itemEnt, slot)
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


local function signalStackSizeChange(self, item, slot, stackSize)
    -- called when a stackSize of an item changes
    local delta = stackSize - item.stackSize
    if delta == 0 then
        return -- not changing anything!
    end
    if delta > 0 then
        signalMoveToSlot(self, slot, item)
    else
        signalRemoveFromSlot(self, slot, item)
    end
    umg.call("items:stackSizeChange", self.owner, item, slot, stackSize)
end


local function setStackSize(self, slot, stackSize)
    local item = self:get(slot)
    if item then
        signalStackSizeChange(self, item, slot, stackSize)
        item.stackSize = stackSize
    end
end





local function assertServer()
    if not server then
        umg.melt("Can only be called on server", 2)
    end
end


local function put(self, slot, itemEnt)
    --[[
        Directly puts an item into a slot
    ]]
    assertNumber(slot)

    -- If `itemEnt` is nil, then it removes the item from inventory.
    self.inventory[slot] = itemEnt
    if itemEnt then
        assertItem(itemEnt)
        if server then
            server.broadcast("items:setInventorySlot", self.owner, slot, itemEnt)
        end
    else
        if server then
            server.broadcast("items:clearInventorySlot", self.owner, slot)
        end
    end
end

function Inventory:rawset(slot, itemEnt)
    --[[
        WARNING:
        This is a very low-level function!!! 
        Only use this if you know what you are doing.

        -> directly sets an item in an inventory
    ]]
    assert(server,"?")
    put(self,slot,itemEnt)
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
            umg.melt("Expects an entity-type of an item (string), or an item-entity!", 2)
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
    local isBlocked = umg.ask("items:isItemAdditionBlocked", invEnt, item, slot)
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


function Inventory:tryAddItem(slot, item)
    canAddToSlotTc(slot, item)
    if self:canAddToSlot(slot, item) then
        add(self, slot, item)
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

    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        local ok = slotHandle:canRemoveItem(item, slot)
        if not ok then return false end
    end

    local invEnt = self.owner
    local isBlocked = umg.ask("items:isItemRemovalBlocked", invEnt, item, slot)
    return not isBlocked
end


function Inventory:tryRemoveItem(slot)
    if self:canRemoveFromSlot(slot) then
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







if server then


local function moveIntoTakenSlot(self, slot, otherInv, otherSlot, count)
    local targ = otherInv:get(otherSlot)
    local item = self:get(slot)
    count = h.getMoveStackCount(item, count, targ)

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
    count = h.getMoveStackCount(item, count)
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
    assertServer()
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
        umg.melt("Not an instance of SlotHandle: " .. tostring(slotHandle))
    end

    slotHandle:setSlotPosition(slot)
    self.slotHandles[slot] = slotHandle
end







function Inventory:canBeAccessedBy(actorEnt)
    return permissions.entityHasPermission(actorEnt, self.owner)
end



local canAddItemTc = typecheck.assert("entity", "number", "entity")
function Inventory:itemCanBeAddedBy(actorEnt, slot, itemToBeAdded)
    -- whether the actorEnt has the authority to add `item` to the slot
    canAddItemTc(actorEnt, slot, itemToBeAdded)
    local isBlocked = umg.ask("items:isItemAdditionBlockedForActorEntity", actorEnt, self.owner, itemToBeAdded, slot)
    return not isBlocked
end


local canRemoveItemTc = typecheck.assert("entity", "number")
function Inventory:itemCanBeRemovedBy(actorEnt, slot)
    -- whether the actorEnt has the authority to remove the item at slot
    canRemoveItemTc(actorEnt, slot)
    local isBlocked = umg.ask("items:isItemRemovalBlockedForActorEntity", actorEnt, self.owner, slot)
    return not isBlocked
end









if client then

local function getAccessCandidates(invEnt)
    --[[
        Gets a list of control-entities that can access invEnt
    ]] 
    local clientId = client.getClient()
    local array = objects.Array()
    local controlEnts = control.getControlledEntities(clientId)
    for _, ent in ipairs(controlEnts) do
        if invEnt:canBeAccessedBy(ent) then
            array:add(ent)
        end
    end
    return array
end


local function getDoubleAccessCandidates(inv1, inv2)
    --[[
        Get a list of control-entities that are able to access BOTH
        inv1 AND inv2.
    ]]
    return getAccessCandidates(inv1):filter(function(controlEnt)
        return inv2:canBeAccessedBy(controlEnt)
    end)
end


local getMoveAccessCandidatesTc = typecheck.assert("table", "number", "table", "number")
local function getMoveAccessCandidates(srcInv, srcSlot, targInv, targSlot)
    getMoveAccessCandidatesTc(srcInv, srcSlot, targInv, targSlot)
    --[[
    gets a list of control-entities that are can move an
    item across inventories, from a slot, to another slot.
    ]]
    local itemEnt = srcInv:get(srcSlot)
    return getDoubleAccessCandidates(srcInv, targInv)
        :filter(function(controlEnt)
            return targInv:itemCanBeAddedBy(controlEnt, targSlot, itemEnt)
        end)
        :filter(function(controlEnt)
            return srcInv:itemCanBeRemovedBy(controlEnt, targSlot)
        end)
end


local function getSwapAccessCandidates(inv1, slot1, inv2, slot2)
    getMoveAccessCandidatesTc(inv1, slot1, inv2, slot2)
    --[[
        gets a set of controlEnts that can swap 2 items in an inventory.
    ]]
    local cand1 = objects.Set(getMoveAccessCandidates(inv1, slot1, inv2, slot2))
    local cand2 = objects.Set(getMoveAccessCandidates(inv2, slot2, inv1, slot1))
    return cand1:intersection(cand2)
end


function Inventory:tryMoveToSlot(srcSlot, targetInv, targetSlot, count)
    --[[
        CLIENTSIDE VERSION:
        Attempts to move an item to a target-slot.
    ]]
    local controlEnt = getMoveAccessCandidates(self,srcSlot, targetInv,targetSlot)[1]
    if controlEnt then
        client.send("items:tryMoveItem",
            controlEnt, 
            self.owner, srcSlot, 
            targetInv.owner, targetSlot, 
            count
        )
    end
end


function Inventory:trySwap(slot1, inv2, slot2)
    --[[
        CLIENTSIDE VERSION:
        Attempts to swap 2 slots.
    ]]
    local controlEnt = getSwapAccessCandidates(self, slot1, inv2, slot2)[1]
    if controlEnt then
        client.send("items:trySwapItems", 
            controlEnt, 
            self.owner, slot1, 
            inv2.owner, slot2
        )
    end
end



client.on("items:setInventorySlot", function(ent, slot, itemEnt)
    put(ent.inventory, slot, itemEnt)
end)

client.on("items:clearInventorySlot", function(ent, slot)
    put(ent.inventory, slot, nil)
end)


end





return Inventory
