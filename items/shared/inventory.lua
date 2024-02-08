

--[[

Inventory objects.

Inventory objects can be extended, to create cooler, custom inventories.
You can also override any part of the rendering, to create custom
inventory backgrounds, custom slots, etc etc.

]]


local SlotHandle = require("shared.SlotHandle")


local Inventory = objects.Class("items_mod:inventory")


local updateStackSize
if server then
    updateStackSize = require("server.update_stacksize")
end

local openInventories
if client then
    openInventories = require("client.open_inventories")
end



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



function Inventory:setup(ent)
    --[[ 
    This is called automatically by the main items system on the server.
    if you intend to use the inventory immediately after creation,
    call this function. 
    ]]
    if self.owner and self.owner ~= ent then
        error("owner is already set to a different inventory!")
    end

    self.owner = ent
end



function Inventory:slotExists(slot)
    -- if out of bounds, return false
    if math.floor(slot) ~= slot then
        return false
    end
    return (slot >= 1) and (slot <= self.size)
end





local floor = math.floor





local function assertItem(item_ent)
    assert(item_ent.itemName, "items need an itemName component")
    assert((not item_ent.description) or type(item_ent.description) == "string", "item entity descriptions must be strings")
    assert((not item_ent.stackSize) or type(item_ent.stackSize) == "number", "item entity stackSize must be a number")
    assert((not item_ent.maxStackSize) or type(item_ent.maxStackSize) == "number", "item entity maxStackSize must be a number")
end



function Inventory:onItemMoved(item, slot)
    -- Override this, if you want
end



local function signalMoveToSlot(self, slot, item_ent)
    -- calls appropriate callbacks for item addition
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemAdded(item_ent, slot)
    end
    self:onItemMoved(item_ent, slot)
    umg.call("items:itemMoved", self.owner, item_ent, slot)
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


local function signalRemoveFromSlot(self, slot, item_ent)
    -- calls appropriate callbacks for item removal
    local slotHandle = self:getSlotHandle(slot)
    if slotHandle then
        slotHandle:onItemRemoved(item_ent, slot)
    end
    self:onItemRemoved(item_ent, slot)
    umg.call("items:itemRemoved", self.owner, item_ent, slot)
end




function Inventory:_rawset(slot, item_ent)
    --[[
        This is a helper function, and SHOULDN'T BE CALLED!!!!
        CALL THIS FUNCTION AT YOUR OWN RISK!
    ]]
    if not self:slotExists(slot) then
        return -- No slot.. can't do anything
    end

    -- TODO: Is it fine to call these callbacks here???
    if item_ent then
        assertItem(item_ent)
        self.inventory[slot] = item_ent
    else
        self.inventory[slot] = nil
    end
end


--[[
    puts an item directly into an inventory.
    BIG WARNING:
    This is a very low-level function, and IS VERY DANGEROUS TO CALL!
    If you want to move inventory items around, take a look at the
    :tryMove  and  :trySwap  methods.

    Calling this function willy-nilly will make it so the same item
        may be duplicated across multiple inventories.
]]
function Inventory:set(slot, item)
    -- DON'T CALL THIS FUNCTION IF YOU ARE UNSURE!!!
    -- Seriously, please!!! Don't be a fakken muppet
    assert(server, "Can only be called on server")
    assertNumber(slot)

    -- If `item_ent` is nil, then it removes the item from inventory.
    self:_rawset(slot, item)
    server.broadcast("items:setInventoryItem", self.owner, slot, item)
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
    for x=1, self.width do
        for y=1, self.height do
            local check_item = self:get(x,y)
            if umg.exists(check_item) then
                -- if its nil, there is no item there.
                if itemName == check_item.itemName then
                    count = count + check_item.stackSize
                end
            end
        end
    end
    return count
end


function Inventory:contains(item_or_itemName)
    for x=1, self.width do
        for y=1, self.height do
            local check_item = self:get(x,y)
            if umg.exists(check_item) then
                -- if its nil, there is no item there.
                if item_or_itemName == check_item.itemName or item_or_itemName == check_item then
                    return true, x, y
                end
            end
        end
    end
    return false
end



function Inventory:getEmptySlot()
    -- Returns the slot of an empty inventory slot
    for slot=1, self.size do
        if not umg.exists(self.inventory[slot]) then
            return slot
        end
    end
end





local hasRemoveAuthorityTc = typecheck.assert("entity", "number")

function Inventory:hasRemoveAuthority(controlEnt, slot)
    --[[
        whether the controlEnt has the authority to remove the
        item at slot
    ]]
    hasRemoveAuthorityTc(controlEnt, slot)
    if not self:canBeOpenedBy(controlEnt) then
        return
    end

    local item = self:get(slot)
    if not item then
        -- cannot remove an empty slot.
        return false 
    end

    local isBlocked = umg.ask("items:isItemRemovalBlockedForControlEntity", controlEnt, self.owner, slot)
    return not isBlocked
end



local hasAddAuthorityTc = typecheck.assert("entity", "table", "number")

function Inventory:hasAddAuthority(controlEnt, itemToBeAdded, slot)
    --[[
        whether the controlEnt has the authority to add
        `item` to the slot (slot)
    ]]
    hasAddAuthorityTc(controlEnt, itemToBeAdded, slot)
    if not self:canBeOpenedBy(controlEnt) then
        return
    end

    local isBlocked = umg.ask("items:isItemAdditionBlockedForControlEntity", controlEnt, self.owner, itemToBeAdded, slot)
    return not isBlocked
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
    if not self:slotExists(slot) then
        return nil
    end

    -- `count` is the number of items that we want to add. (defaults to the full stackSize of item)
    count = (count or item.stackSize) or 1

    local item_ent = self:get(slot)
    if item_ent then
        if not canCombineStacks(item, item_ent, count) then
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
    if not umg.exists(item) then
        return true -- no item, so I guess we can remove
    end

    local invEnt = self.owner
    local isBlocked = umg.ask("items:isItemRemovalBlocked", item, invEnt, slot)
    return not isBlocked
end



function Inventory:tryRemoveFromSlot(slot)
    --[[
        tries to remove item from an inventory slot.
        On success, returns the removed item.
        On failure, returns nil.
    ]]
    local item = self:get(slot)
    if not umg.exists(item) then
        -- no item to remove
        return nil
    end

    if self:canRemoveFromSlot(slot) then
        self:remove(slot)
    end
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
        if umg.exists(item) and item == item_or_itemName or item.itemName == item_or_itemName then
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



local addTc = typecheck.assert("number", "entity")
function Inventory:add(slot, item)
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
        self:set(slot, item)
    end
end


function Inventory:remove(slot)
    -- WARNING: Somewhat unsafe to call!!!
    -- Directly removes an item from a slot in an inventory.
    -- This is kinda like deleting the item.
    local item = self:get(slot)
    if umg.exists(item) then
        signalRemoveFromSlot(self, slot, item)
    end
    self:set(slot, nil)
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
    updateStackSize(item)
    signalStackSizeChange(self, slot, change)
end





function Inventory:canBeOpenedBy(ent)
    --[[
        we ask two questions here,
        one for whether the inventory can be opened,
        another for whether the inventory is locked.

        This provides a lot of flexibility.
    ]]
    assert(umg.exists(ent), "takes an entity as first argument. (Where the entity is the one opening the inventory)")

    local canOpen = umg.ask("items:canOpenInventory", ent, self)
    if canOpen then
        local isLocked = umg.ask("items:isInventoryLocked", ent, self)
        if not isLocked then
            return true
        end
    end
end



function Inventory:open()
    assert(client, "Only available client-side")
    umg.call("items:openInventory", self.owner)
    openInventories.open(self)
    self.is_open = true
end


function Inventory:close()
    assert(client, "Only available client-side")
    umg.call("items:closeInventory", self.owner)
    openInventories.close(self)
    self.is_open = false
end



function Inventory:isOpen()
    return self.is_open
end




function Inventory:get(slot)
    assertNumber(slot)
    return self.inventory[slot]
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











--[[
Warning: 
Yucky, bad rendering code below this point!!!
Read at your own risk!  :-)
]]


function Inventory:withinBounds(mouse_x, mouse_y)
    -- returns true/false, depending on whether mouse_x or mouse_y is
    -- within the inventory interface
    local ui_scale = rendering.getUIScale()
    local mx, my = mouse_x / ui_scale, mouse_y / ui_scale
    local x,y,w,h = self:getDrawBounds()
    local x_valid = (x <= mx) and (mx <= x+w)
    local y_valid = (y <= my) and (my <= y+h)
    return x_valid and y_valid
end


function Inventory:getSlotFromMousePosition(mouse_x, mouse_y)
    --[[
        gets the slot that's being hovered,
        given a mouse position.
    ]]
    local ui_scale = rendering.getUIScale()
    local x, y = mouse_x / ui_scale, mouse_y / ui_scale
    local norm_x = x - self.draw_x 
    local norm_y = y - self.draw_y

    local bx, by = norm_x % self.totalSlotSize, norm_y % self.totalSlotSize
    local bo = (self.totalSlotSize - self.slotSize) / 2
    if bx > bo and bx < (self.totalSlotSize - bo) and by > bo and by < (self.totalSlotSize - bo) then
        local ix = floor(norm_x / self.totalSlotSize) + 1
        local iy = floor(norm_y / self.totalSlotSize) + 1
        if ix >= 1 and ix <= self.width and iy >= 1 and iy <= self.height then
            return ix, iy
        end
    end
end


local WHITE = {1,1,1}

function Inventory:drawItem(item_ent, x, y)
    love.graphics.push()
    love.graphics.setColor(item_ent.color or WHITE)

    local quad = client.assets.images[item_ent.image]
    local _,_, w,h = quad:getViewport()

    local offset = (self.totalSlotSize - w) / 2
    local X = self.totalSlotSize * (x-1) + offset + self.draw_x
    local Y = self.totalSlotSize * (y-1) + offset + self.draw_y

    local drawX, drawY = X + w/2, Y + w/2
    local maxSize = math.max(w, h)
    local scale = self.slotSize / maxSize
    rendering.drawImage(quad, drawX, drawY, 0, scale, scale)

    local holder_ent = self.owner
    umg.call("items:drawInventoryItem", holder_ent, item_ent, drawX, drawY, self.slotSize)

    if (item_ent.stackSize or 1) > 1 then
        -- Draw stack number
        love.graphics.push()
        love.graphics.translate(X-2,Y-2)
        love.graphics.scale(0.5)
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(item_ent.stackSize, -1,0)
        love.graphics.print(item_ent.stackSize, 1,0)
        love.graphics.print(item_ent.stackSize, 0,1)
        love.graphics.print(item_ent.stackSize, 0,-1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(item_ent.stackSize, 0,0)
        love.graphics.pop()
    end
    love.graphics.pop()
end





--[[
    TODO:

    Create a well-defined API 
    for rendering item tooltips.
]]



local sqrt = math.sqrt



local function drawHighlights(draw_x, draw_y, W, H, r,g,b, offset, concave)
    offset = offset or 2
    local x = draw_x+offset
    local y = draw_y+offset
    local w,h = W-offset*2, H-offset*2

    if concave then
        love.graphics.setColor(sqrt(r)+0.1, sqrt(g)+0.1, sqrt(b)+0.1)
    else
        love.graphics.setColor(r*r-0.1, g*g-0.1, b*b-0.1)
    end
    love.graphics.line(x+w, y, x+w, y+h)
    love.graphics.line(x, y+h, x+w, y+h)

    if concave then
        love.graphics.setColor(r*r-0.1, g*g-0.1, b*b-0.1)
    else
        love.graphics.setColor(sqrt(r)+0.1, sqrt(g)+0.1, sqrt(b)+0.1)
    end
    love.graphics.line(x, y, x+w+1, y)
    love.graphics.line(x, y, x, y+h+1)
end


function Inventory:drawSlot(slot, offset, color)
    local x, y = inv_x - 1, inv_y - 1 -- inventory is 1 indexed
    local X = math.floor(self.draw_x + x * self.totalSlotSize + offset)
    local Y = math.floor(self.draw_y + y * self.totalSlotSize + offset)

    love.graphics.setLineWidth(1)

    local r,g,b = color[1] / 1.5, color[2] / 1.5, color[3] / 1.5
    love.graphics.setColor(r,g,b)
    love.graphics.rectangle("fill", X, Y, self.slotSize, self.slotSize)

    drawHighlights(X, Y, self.slotSize, self.slotSize, r,g,b, 1, true)

    -- love.graphics.setColor(0,0,0)
    -- love.graphics.rectangle("line", X, Y, self.slotSize, self.slotSize)

    if self:get(slot) then
        local item = self:get(slot)
        if umg.exists(item) then
            -- only draw the item if it exists.
            self:drawItem(item, slot)
        else
            self:set(slot, nil)
            -- woops!!! dunno what happened here lol!
        end
    end
end






local EXIT_BUTTON_SIZE = 8
local EXIT_BUTTON_BORDER = 3

local EXTRA_TOP_BORDER = 8

function getExitButtonBounds(self)
    local x,y,w,h = self:getDrawBounds()
    local bx = x + w - EXIT_BUTTON_SIZE - EXIT_BUTTON_BORDER
    local by = y + EXIT_BUTTON_BORDER
    return bx,by, EXIT_BUTTON_SIZE,EXIT_BUTTON_SIZE
end


function Inventory:withinExitButtonBounds(mouse_x, mouse_y)
    -- returns true/false, depending on whether mouse_x or mouse_y is
    -- within the exit button region
    local ui_scale = rendering.getUIScale()
    local mx, my = mouse_x / ui_scale, mouse_y / ui_scale
    local x,y,w,h = getExitButtonBounds(self)
    local x_valid = (x <= mx) and (mx <= x+w)
    local y_valid = (y <= my) and (my <= y+h)
    return x_valid and y_valid
end



function Inventory:getDrawBounds()
    assert(client, "Shouldn't be called serverside")
    -- total width/height of inventory
    local w = self.width * self.totalSlotSize + self.borderWidth * 2
    local h = self.height * self.totalSlotSize + self.borderWidth * 2 + EXTRA_TOP_BORDER

    -- the top-left coords of inventory
    local x = self.draw_x - self.borderWidth
    local y = self.draw_y - self.borderWidth - EXTRA_TOP_BORDER
    return x,y, w,h
end





function Inventory:drawExitButton(x,y,w,h)
    love.graphics.setLineWidth(1)
    local col = self.color or WHITE
    love.graphics.setColor(col)
    love.graphics.rectangle("fill", x,y,w,h)

    love.graphics.setColor(col[1]/2, col[2]/2, col[3]/2)
    love.graphics.line(x,y, x+w,y+h)
    love.graphics.line(x+w,y, x,y+h)

    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", x,y,w,h)
end




local function getInventoryName(self)
    local ent = self.owner
    return (ent.inventoryName or self.name)
end



local INVENTORY_NAME_OFFSET = 4

function Inventory:drawInventoryName()
    local name = getInventoryName(self)
    if not name then
        return
    end

    local x,y,_,_ = self:getDrawBounds()
    local X = x + INVENTORY_NAME_OFFSET
    local Y = y + INVENTORY_NAME_OFFSET
    local font = love.graphics.getFont()
    local w,h = font:getWidth(name), font:getHeight()
    local scale = EXTRA_TOP_BORDER / h
    love.graphics.setColor(0,0,0,1)
    love.graphics.print(name, X,Y,0,scale,scale)
end



function Inventory:drawHoverWidget(slot)
    --[[
        if the player is picking up an item,
        and about to move it, this stuff will be drawn!
    ]]
    local item = self:get(slot)
    if not umg.exists(item) then return end
    local mx, my = love.mouse.getPosition()
    local ui_scale = rendering.getUIScale()
    mx, my = mx / ui_scale, my / ui_scale
    love.graphics.push("all")
    love.graphics.setLineWidth(3)
    love.graphics.setColor(1,1,1,0.7)
    local ix = (slotX-1) * self.totalSlotSize + self.draw_x + self.totalSlotSize/2
    local iy = (slotY-1) * self.totalSlotSize + self.draw_y + self.totalSlotSize/2
    love.graphics.line(mx, my, ix, iy)
    love.graphics.setColor(1,1,1)
    love.graphics.circle("fill", mx,my, 2)
    love.graphics.pop()
end



function Inventory:drawBackground(x, y, w, h)
    -- Draw inventory body
    local col = self.color or WHITE
    love.graphics.setColor(col) 
    love.graphics.rectangle("fill", x, y, w, h)
end


function Inventory:drawForeground(x, y, w, h)
    local col = self.color or WHITE
    love.graphics.setLineWidth(2)
    drawHighlights(x, y, w, h, col[1],col[2],col[3])

    -- Draw outline
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", x, y, w, h)
    self:drawInventoryName()
end


function Inventory:drawUI()
    assert(client, "Shouldn't be called serverside")
    if not self:isOpen() then
        return
    end

    love.graphics.push("all")
    -- No need to scale for UI- this should be done by draw system.

    local X,Y,W,H = self:getDrawBounds()

    local col = self.color or WHITE
    
    love.graphics.setLineWidth(2)
    
    self:drawBackground(X,Y,W,H)

    local offset = self.slotSeparation / 2

    -- draw interior
    for slot=1, self.size do
        self:drawSlot(slot, offset, col)
    end

    self:drawForeground(X,Y,W,H)

    do 
        local x,y,w,h = getExitButtonBounds(self)
        self:drawExitButton(x,y,w,h)
    end

    umg.call("items:drawInventory", self.owner, X,Y,W,H)
    
    love.graphics.pop()
end



return Inventory
