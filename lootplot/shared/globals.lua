
--[[

Global api helper methods.

]]



local api = {}


function api.setSlot(ppos, slotEnt)
    -- directly sets a slot
    assert(umg.exists(slotEnt), "?")
    ppos.plot:set(ppos.slot, slotEnt)
    update(slotEnt, ppos)
end



function api.getItem(ppos)
    local slotEnt = getSlot(ppos)
    if slotEnt and umg.exists(slotEnt.item) then
        return slotEnt.item
    end
end

function api.getSlot(ppos)
    
end


function api.setItem(ppos, itemEnt)
    local slotEnt = getSlot(ppos)
    if slotEnt and umg.exists(slotEnt.item) then
        slotEnt.item = itemEnt
        sync.syncComponent(slotEnt, "item")
        update(itemEnt)
    end
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


function api.rotate(ent, angle)
    -- rotates item by an angle.
    local e = getItem(ppos)
end


function api.trySpawnItem(ppos, itemEType)
    local slot = getSlot(ppos)
    if slot then
        local itemEnt = spawn(itemEType)
        setItem(ppos, itemEnt)
    end
end

function api.sell(ent)
    -- sells entity
    sellEnt(e)
end


-- burn(ppos)  TODO



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


