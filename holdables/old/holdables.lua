
--[[

READ-ME::
READ-ME::
READ-ME::
READ-ME::
READ-ME::
READ-ME::


]]


-- an entity equips an item
umg.defineEvent("holdables:equipItem")
-- an entity un-equips an item
umg.defineEvent("holdables:unequipItem")


sync.proxyEventToClient("holdables:equipItem")
sync.proxyEventToClient("holdables:unequipItem")




--[[
Represents a slot in the inventory, where if an item goes to that slot,
the item is automatically equipped.
If the item is removed from that slot, then the item is automatically
unequipped.
]]
local HoldSlotHandle = objects.Class("holdables:HoldSlotHandle")
    :implement(items.SlotHandle)

local holding = require("shared.holding")
function HoldSlotHandle:onItemAdded(itemEnt)
    if server then
        local holderEnt = self:getOwner()
        if itemEnt.holdable then
            holding.equipItem(holderEnt, itemEnt)
        end
    end
end
function HoldSlotHandle:onItemRemoved(itemEnt)
    if server then
        local holderEnt = self:getOwner()
        holding.unequipItem(holderEnt, itemEnt)
    end
end





if client then
local controllableGroup = umg.group("inventory", "controllable", "clickToUseHoldItem")
local listener = input.InputListener()
input.addListener(listener, 2)

local function useItems()
    local used = false
    for _, ent in ipairs(controllableGroup) do
        if sync.isClientControlling(ent) then
            local wasUsed = useHoldItem(ent)
            used = used or wasUsed
        end
    end
    return used
end

listener:onPressed("input:CLICK_PRIMARY", function(self, controlEnum)
    local used = useItems()
    if used then
        -- only lock if an item was actually used
        self:claim(controlEnum)
    end
end)

end
