
--[[

Global api helper methods.

]]

local ptrack = require("shared.positionTracking")



local api = {}


function api.setSlot(ppos, slotEnt)
    -- directly sets a slot
    assert(umg.exists(slotEnt), "?")
    ppos.plot:set(ppos.slot, slotEnt)
    ptrack.set(slotEnt, ppos)
end

function api.getSlot(ppos)
    local ent = ppos.plot:get(ppos.slot)
    if umg.exists(ent) then
        return ent
    end
end



local posTc = typecheck.assert("ppos")
local ent2Tc = typecheck.assert("entity", "entity")


function api.getItem(ppos)
    posTc(ppos)
    local slotEnt = getSlot(ppos)
    if slotEnt and umg.exists(slotEnt.item) then
        return slotEnt.item
    end
end

function api.setItem(slotEnt, itemEnt)
    ent2Tc(slotEnt, itemEnt)
    if umg.exists(slotEnt) then
        slotEnt.item = itemEnt
        sync.syncComponent(slotEnt, "item")
        ptrack.set(itemEnt, ppos)
    end
end



function api.getPos(ent)
    -- Gets the ppos of an ent
    local ppos = ptrack.get(ent)
    return ppos
end



function api.detach(item)
    local ppos = ptrack.get(item)
    if not ppos then
        return
    end
    local slot = getSlot(ppos)
    if slot then
        slo
        error([[
            todo:
            plan thru ALLL of this shit.
            Plan thru it all.
        ]])
    end
end


local function attach(slotEnt, item)

end


function api.move(item, ppos)
    -- moves an item to a position
    detach(item)
    attach(getSlot(ppos), item)
end



function api.swap(item1, item2)
    ent2Tc(item1, item2)
    local p1, p2 = ptrack.get(item1), ptrack.get(item2)
    assert(p1 and p2, "Cannot swap nil-position")
    detach(item1)

    error[[
        todo
    ]]
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
    local slot = getSlot(ppos)
    if slot then
        local itemEnt = spawn(itemEType)
        setItem(ppos, itemEnt)
    end
end



function api.copySlot(srcPos, targPos)
    
end

copy(srcPos, targPos) -- copies an item
copySlot(srcPos, targPos) -- copies a slot!




--[[
    exported globally for convenience.
]]
for k,v in pairs(api) do
    _G[k] = v
end


umg.expose("lootplot", api)

return api


