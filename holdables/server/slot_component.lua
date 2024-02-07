
--[[

holdItemSlot component -> 
{
    slot = 2
}

if an item gets put in the slot, then it is automatically equipped.

]]


local HoldSlotHandle = require("shared.hold_slot_handle")


local group = umg.group("inventory", "holdItemSlot")

group:onAdded(function(ent)
    local inv = ent.inventory
    local his = ent.holdItemSlot

    local obj = HoldSlotHandle(inv)
    inv:setSlotHandle(his.slot, obj)
end)

