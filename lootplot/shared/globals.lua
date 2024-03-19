
--[[

Global api helper methods.

]]

local ptrack = require("shared.positionTracking")



local api = {}



--[[
    Positioning:
]]
local posTc = typecheck.assert("ppos")

function api.posToSlot(ppos)
    posTc(ppos)
    local ent = ppos.plot:get(ppos.slot)
    if umg.exists(ent) then
        return ent
    end
end

function api.posToItem(ppos)
    posTc(ppos)
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






--[[
    DIRECTIONS:
]]







local setSlotTc = typecheck.assert("ppos", "entity")

function api.setSlot(ppos, slotEnt)
    -- directly sets a slot
    setSlotTc(ppos, slotEnt)
    local prevEnt = posToItem(ppos)
    if prevEnt then
        destroy(prevEnt)
    end
    ppos.plot:set(ppos.slot, slotEnt)
    ptrack.set(slotEnt, ppos)
end










--[[
    Movement of items:
]]

local function _detachItem(item)
    -- removes an entity from a plot. position info is nilled.
    local ppos = ptrack.get(item)
    local slot = ppos and posToItem(ppos)
    if (not slot) or (slot.item ~= item) then
        return
    end
    -- OK: Item is upon the slot, we just need to remove it.
    slot.item = nil
    ptrack.set(item, nil)
end
api.detachItem = sync.newDualFunction(_detachItem, "detachItem", {
    typelist = {"entity"},
    serverOnly = true
})


local function _attachItem(slotEnt, item)
    assert(not ptrack.get(item), "Item attached somewhere else")
    local ppos = getPos(slotEnt)
    if umg.exists(slotEnt.item) then
        -- if item already exists: Destroy it and overwrite.
        destroy(slotEnt.item)
    end
    slotEnt.item = item
    ptrack.set(item, ppos)
end
api.attachItem = sync.newDualFunction(_attachItem, "attachItem", {
    typelist = {"entity", "entity"},
    serverOnly = true
})




local function ensureSlot(slotEnt_or_ppos)
    --[[
        Takes a slotEnt OR ppos,
        and returns a slotEnt.

        If anything is invalid, throws error.
    ]]
    local ppos
    if ptrack.get(slotEnt_or_ppos) then
        -- its a slotEnt!
        ppos = getPos(slotEnt_or_ppos)
    else
        ppos = slotEnt_or_ppos
    end

    local slotEnt = posToSlot(ppos)
    if not slotEnt then
        error("Invalid slot-entity (or position) for slot!", 3)
    end
    return slotEnt
end


function api.moveItem(item, slotEnt_or_ppos)
    -- moves an item to a position
    assert(server, "?")
    local slotEnt = ensureSlot(slotEnt_or_ppos)
    detachItem(item)
    attachItem(slotEnt, item)
end


local ent2Tc = typecheck.assert("entity", "entity")
function api.swapItem(item1, item2)
    ent2Tc(item1, item2)
    local slot1, slot2 = posToSlot(getPos(item1)), posToSlot(getPos(item2))
    assert(slot1 and slot2, "Cannot swap nil-position")
    detachItem(item1)
    detachItem(item2)
    attachItem(item1, slot1)
    attachItem(item2, slot2)
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
    assert(server,"?")
    if umg.exists(ent) then
        ptrack.set(ent, nil)
        health.kill(ent)
    end
end


function api.sellItem(ent)
    error("nyi")
end

function api.rotate(ent, angle)
    -- rotates item by an angle.
    local e = posToItem(ppos)
end

function api.clone(ent)
    local cloned = ent:clone()
    --[[
        TODO: emit events here
    ]]
    return cloned
end

function api.rerollItem(slotEnt_or_ppos)
    local slotEnt = ensureSlot(slotEnt_or_ppos)
    local ppos = getPos(slotEnt)
    local itemEnt = posToItem(ppos)
    -- destroy item,
    destroy(itemEnt) 
    -- then, create a new item:
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


