





local controlInventoryGroup = umg.group("controller", "inventory")








--[[
    The inventory, along with the x and y of the item
    that the player is holding.
]]
local focus_inv -- The inventory that is currently being focused

-- OLD:
local focus_x -- X pos in holding inv
local focus_y -- Y pos in holding inv

local focus_slot -- the slot that is being focused

local focus_half_stack -- whether only half a stack is being held
-- (This is true if it was picked up by BETA_BUTTON. (right click))




-- The inventory that is being dragged around by the player
local dragging_inv



inventoryGroup:onRemoved(function(ent)
    local inv = ent.inventory
    if focus_inv == inv then
        focus_inv, focus_slot = nil, nil
    end
    openInventories.close(inv)
end)



umg.on("items:closeInventory", function(owner_ent)
    -- todo: This is slightly hacky?
    -- We shouldn't be using callbacks to determine critical state like this.
    local inv = owner_ent.inventory

    if focus_inv == inv then
        -- stop holding of item
        focus_inv = nil
        focus_x = nil
        focus_y = nil
    end
end)




local function resetHoldingInv()
    focus_inv = nil
    focus_x = nil
    focus_y = nil
    focus_half_stack = nil
end


local function getControlEntity(inv)
    for _, ent in ipairs(controlInventoryGroup) do
        if sync.isClientControlling(ent) then
            if inv:canBeOpenedBy(ent) then
                return ent
            end
        end
    end
    return false
end


local function getControlTransferEntity(inv1, inv2)
    --[[
        Players can only move things around inventories
        if they have a controlEnt that can facilitate the transer.

        look through all controlled entities, filter for
        the ones controlled by the client, and return any that
        are able to make the transfer between inv1 and inv2.
    ]]
    for _, ent in ipairs(controlInventoryGroup) do
        if sync.isClientControlling(ent) then
            if inv1:canBeOpenedBy(ent) then
                if inv2 == inv1 or inv2:canBeOpenedBy(ent) then
                    return ent
                end
            end
        end
    end
    return false
end



local function moveItem(controlEnt, targetInventory, targetSlot, count)
    -- Moves `count` items from the focused inventory,
    -- to some target inventory.
    local srcEnt = focus_inv.owner
    local srcSlot = focus_slot
    local targetEnt = targetInventory.owner
    client.send("inventory:tryMoveInventoryItem", controlEnt, srcEnt, targetEnt, srcSlot, targetSlot, count)
end



local function executeFullPut(inv, x, y)
    local controlEnt = getControlTransferEntity(inv, focus_inv)

    -- Ok... so `holding` exists.
    local holding = focus_inv:get(focus_slot)
    if not umg.exists(holding) then
        resetHoldingInv()
        return -- erm, okay? I guess the entity was deleted, so we just ignore this
    end

    if (inv==focus_inv) and (x==focus_x) and (y==focus_y) then
        resetHoldingInv()
        return -- moving an item to it's own position...? nope!
    end

    local swapping = false
    local move_count
    local targ = inv:get(x,y)
    if targ then
        if targ.itemName == holding.itemName then
            if targ.stackSize == targ.maxStackSize and holding.stackSize == holding.maxStackSize then
                swapping = true
            else
                -- they stack!  (no need to swap)
                swapping = false
                local div = focus_half_stack and 2 or 1
                move_count = math.min(math.ceil(holding.stackSize/div), targ.maxStackSize - targ.stackSize)
            end            
        else
            swapping = true
        end
    end

    if swapping then
        client.send("inventory:trySwapInventoryItem", controlEnt, focus_inv.owner, inv.owner, focus_x,focus_y, x,y)
    else
        if not move_count then
            move_count = math.ceil(holding.stackSize / (focus_half_stack and 2 or 1))
        end
        moveItem()
    end

    resetHoldingInv()
end




local function executeAlphaInteraction(inv, slot_x, slot_y)
    --[[
        "alpha" interactions are for stuff like placing full stacks
        of items, etc.
    ]]
    if focus_inv and umg.exists(focus_inv.owner) and focus_inv:get(focus_slot) then
        executeFullPut(inv, slot_x, slot_y)
    else
        -- Else we just set the holding to a value, so long as there is an item
        -- in the target slot:
        focus_inv = inv
        focus_x = slot_x
        focus_y = slot_y
        focus_half_stack = false
        if not inv:get(slot_x,slot_y) then
            resetHoldingInv()
        end
    end
end


local function executeBetaInteraction(inv, x, y)
    --[[
        "beta" interactions are for placing one item out of an entire stack,
        or splitting a stack.
    ]]
    if focus_inv and umg.exists(focus_inv.owner) and focus_inv:get(focus_slot) then
        local controlEnt = getControlTransferEntity(inv, focus_inv)
        local holding_item = focus_inv:get(focus_slot)
        local targ = inv:get(x,y)
        if (not targ) or targ.itemName == holding_item.itemName then
            client.send("inventory:tryMoveInventoryItem", controlEnt, focus_inv.owner, inv.owner, focus_x,focus_y, x,y, 1)
        end
    else
        focus_inv = inv
        focus_x = x
        focus_y = y
        focus_half_stack = true
        if not inv:get(x,y) then
            resetHoldingInv()
        end
    end
end


local ALPHA_BUTTON = 1
local BETA_BUTTON = 2 -- right click is clearly inferior 


local listener = input.Listener({priority = 5})





local function inventoryMousePress(listenr, inv, mx, my, button)
    --[[
        called when the mouse is pressed, and we are within an inventory
    ]]
    openInventories.focus(inv)
    local slot = inv:getSlotFromMousePosition(mx,my)
    if slot then
        if inv:slotExists(slot) then
            if button == ALPHA_BUTTON then
                listenr:lockMouseButton(ALPHA_BUTTON)
                executeAlphaInteraction(inv, slot)
            elseif button == BETA_BUTTON then
                listenr:lockMouseButton(BETA_BUTTON)
                executeBetaInteraction(inv, slot)
            end
        elseif button == ALPHA_BUTTON then
            listenr:lockMouseButton(ALPHA_BUTTON)
            dragging_inv = inv
            resetHoldingInv()
        end
    elseif button == ALPHA_BUTTON then
        listenr:lockMouseButton(ALPHA_BUTTON)
        dragging_inv = inv
        resetHoldingInv()
    end
end


function listener:mousepressed(mx, my, button)
    local openInvs = openInventories.getOpenInventories()
    local len = #openInvs
    local loop_used = false
    for i=len, 1, -1 do
        local inv = openInvs[i]
        if inv:withinBounds(mx, my) then
            loop_used = true
            if button == ALPHA_BUTTON and inv:withinExitButtonBounds(mx, my) then
                self:lockMouseButton(ALPHA_BUTTON)
                inv:close()
            else
                inventoryMousePress(self, inv, mx, my, button)
            end
            break -- Only one interaction per inventory allowed.
        end
    end

    if (not loop_used) and focus_inv then
        if button == ALPHA_BUTTON then    
            -- Then the player wants to drop an item on the floor:
            if umg.exists(focus_inv:get(focus_slot)) then
                local controlEnt = getControlEntity(focus_inv)
                client.send("inventory:tryDropInventoryItem", controlEnt, focus_inv.owner, focus_slot)
            end
            self:lockMouseButton(ALPHA_BUTTON)
        elseif button == BETA_BUTTON then
            resetHoldingInv()
            self:lockMouseButton(BETA_BUTTON)
        end
    end
end


function listener:mousemoved(mx,my, dx, dy)
    -- used for dragging inventories around
    if dragging_inv then
        dragging_inv.draw_x = dragging_inv.draw_x + dx
        dragging_inv.draw_y = dragging_inv.draw_y + dy
    end
end


function listener:mousereleased(mx,my, button)
    dragging_inv = nil
end



umg.on("rendering:drawUI", function()
    for _, inv in ipairs(openInventories.getOpenInventories()) do
        inv:drawUI()
    end
    
    if focus_inv then
        focus_inv:drawHoverWidget(focus_slot)
    end
end)


