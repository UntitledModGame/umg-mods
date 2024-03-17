
--[[

Global LOOTPLOT helper methods.




]]

local lootplot = {}

function lootplot.get(ppos)
    -- gets a slot from a ppos
    return ppos.plot:get(ppos.slot)
end

function lootplot.set(ppos, slotEnt)
    -- directly sets a slot
    assert(umg.exists(slotEnt), "?")
    ppos.plot:set(ppos.slot, slotEnt)
end



local function getSlot(ppos_or_ent)
    if umg.exists(ppos_or_ent) then 
        return ppos_or_ent -- its an ent!
    else
        -- its a ppos! (Return the slot-entity)
        return get(ppos_or_ent)
    end
end

local function getItem(ppos_or_ent)
    local slotEnt = getSlot(ppos_or_ent)
    if slotEnt and umg.exists(slotEnt.item) then
        return slotEnt.item
    end
end


function lootplot.activate(ppos_or_ent)
    local e = getSlot(ppos_or_ent)
    if e then
        activateEnt(e)
    end
end


function lootplot.destroySlot(ppos_or_ent)
    local e = getSlot(ppos_or_ent)
    if e then
        destroyEnt(e)
    end
end


function lootplot.destroy(ppos_or_ent)
    local e = getItem(ppos_or_ent)
    if e then
        destroyEnt(e)
    end   
end


function lootplot.rotate(ppos, angle)
    -- rotates item by an angle.
    local e = getItem(ppos)
end


function lootplot.trySpawn(ppos, itemEType)
    local slot = getSlot(ppos)
    if slot then
        local itemEnt = itemEType()
        set()
    end
end

function lootplot.sell(ppos)
    -- sells item at ppos
    local e = getItem(ppos)
    if e then
        sellEnt(e)
    end
end


-- burn(ppos)  TODO




copy(srcPos, targPos) -- copies an item
copySlot(srcPos, targPos) -- copies a slot!




--[[
    exported globally for convenience.
]]
for k,v in pairs(lootplot) do
    _G[k] = v
end

return lootplot
