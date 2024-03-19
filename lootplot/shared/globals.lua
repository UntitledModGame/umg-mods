
--[[

Global api helper methods.

]]

local ptrack = require("shared.positionTracking")



local api = {}



--[[
    Positioning:
]]

function api.posToSlot(ppos)
    local ent = ppos.plot:get(ppos.slot)
    if umg.exists(ent) then
        return ent
    end
end

function api.posToItem(ppos)
    local slot = api.posToSlot(ppos)
    if slot and umg.exists(slot.item) then
        return slot.item
    end
end

function api.getPos(ent)
    -- Gets the ppos of an ent
    local ppos = ptrack.get(ent)
    return ppos
end




local posTc = typecheck.assert("ppos")
local ent2Tc = typecheck.assert("entity", "entity")


function api.setSlot(ppos, slotEnt)
    -- directly sets a slot
    assert(umg.exists(slotEnt), "?")
    local prevEnt = posToItem(ppos)
    if prevEnt then
        destroy(prevEnt)
    end
    ppos.plot:set(ppos.slot, slotEnt)
    ptrack.set(slotEnt, ppos)
end





function api.getItem(ppos)
    posTc(ppos)
    local slotEnt = posToItem(ppos)
    if slotEnt and umg.exists(slotEnt.item) then
        return slotEnt.item
    end
end




function api.detach(item)
    -- removes an entity from a plot. position info is nilled.
    local ppos = ptrack.get(item)
    local slot = ppos and posToItem(ppos)
    if (not slot) or (slot.item ~= item) then
        return
    end
    -- OK: Item is upon the slot, we just need to remove it.
    slot.item = nil
    ptrack.set(item, nil)
    -- TODO: Do callback here...?
    --[[
        hmm,
        we somehow need to sync this operation to the client.
        Maybe a dual-function?
    ]]
end


function api.attach(slotEnt, item)
    assert(not ptrack.get(item), "Item already attached somewhere else")
end


function api.move(item, ppos_or_slotEnt)
    -- moves an item to a position
    detach(item)
    attach(posToItem(ppos), item)

    if umg.exists(slotEnt) then
        slotEnt.item = itemEnt
        sync.syncComponent(slotEnt, "item")
        ptrack.set(itemEnt, ppos)
    end
end



function api.swap(item1, item2)
    ent2Tc(item1, item2)
    local p1, p2 = ptrack.get(item1), ptrack.get(item2)
    assert(p1 and p2, "Cannot swap nil-position")
    detach(item1)
    detach(item2)
    move(item1, p2)
    move(item2, p1)
end



function api.activate(ent)
    if umg.exists(ent) then
        --[[
            todo: prolly need to tag into some API here
        ]]
        activateEnt(ent)
    end
end


function api.destroy(ent)
    if umg.exists(ent) then
        ent:delete()
    end
end


function api.sell(ent)
    error("nyi")
end

function api.rotate(ent, angle)
    -- rotates item by an angle.
    local e = getItem(ppos)
end



function api.clone(ent)
    local cloned = ent:clone()
    --[[
        TODO: emit events here
    ]]
    return cloned
end


function api.trySpawnItem(ppos, itemEType)
    local slot = posToItem(ppos)
    if slot then
        local itemEnt = spawn(itemEType)
        setItem(ppos, itemEnt)
    end
end





--[[
    exported globally for convenience.
]]
for k,v in pairs(api) do
    _G[k] = v
end


umg.expose("lootplot", api)

return api


