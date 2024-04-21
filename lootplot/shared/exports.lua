
--[[

Global api helper methods.

]]

local ptrack = require("shared.internal.positionTracking")



local lp = {}



if server then
local bufferTc = typecheck.assert("ppos", "function")
function lp.buffer(ppos, func)
    --[[
        basic action-buffering, with 0 arguments for function.
    ]]
    bufferTc(ppos, func)
    ppos.plot:buffer(func)
end

local waitTc = typecheck.assert("ppos", "number")
function lp.wait(ppos, time)
    waitTc(ppos, time)
    ppos.plot:wait(time)
end

lp.Bufferer = require("server.Bufferer")
end



lp.PPos = require("shared.PPos")

lp.Plot = require("shared.Plot")


lp.posTc = typecheck.assert("ppos")

--[[
    Positioning:
]]
function lp.posToSlot(ppos)
    lp.posTc(ppos)
    return ppos.plot:getSlot(ppos.slot)
end

function lp.posToItem(ppos)
    lp.posTc(ppos)
    local slot = lp.posToSlot(ppos)
    if slot and umg.exists(slot.item) then
        return slot.item
    end
end

function lp.getPos(ent)
    -- Gets the ppos of an ent
    local ppos = ptrack.get(ent)
    return ppos
end




--[[
    everything in this table must be overridden
    by some playable lootplot mod.
]]
lp.overrides = {}

function lp.overrides.setPoints(ent, x)
    -- sets points for `ent`s context
    umg.melt("MUST OVERRIDE")
end
function lp.overrides.getPoints(ent)
    -- gets points for `ent`s context
    umg.melt("MUST OVERRIDE")
end
function lp.overrides.setMoney(ent, x)
    -- sets money for `ent`s context
    umg.melt("MUST OVERRIDE")
end
function lp.overrides.getMoney(ent)
    -- gets money for `ent`s context
    umg.melt("MUST OVERRIDE")
end





--[[
    Money/point services:
]]
do
local modifyTc = typecheck.assert("entity", "number")

--[[
`fromEnt` is the entity that applied the point modification.
(IE a slot, or an item.)

Depending on the gamemode; this will be handled in different ways.
]]
local function modifyPoints(fromEnt, x)
    assert(server,"??")
    local multiplier = umg.ask("lootplot:getPointMultiplier", fromEnt, x)
    local val = x*multiplier
    if val > 0 then
        umg.call("lootplot:pointsAdded", fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:pointsSubtracted", fromEnt, val)
    end
    lp.setPoints(fromEnt, val)
end

function lp.setPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    lp.overrides.setPoints(fromEnt, -x)
    umg.call("lootplot:setMoney", fromEnt, x)
end
function lp.addPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyPoints(fromEnt, x)
end
function lp.subtractPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyPoints(fromEnt, -x)
end

function lp.getPoints(ent)
    return lp.overrides.getPoints(ent)
end



--[[
`fromEnt` is the entity that applied the money modification.
(So for example, it could be a slot, or an item.)
]]
local function modifyMoney(fromEnt, x)
    assert(server,"??")
    local multiplier = umg.ask("lootplot:getMoneyMultiplier", fromEnt)
    local val = x*multiplier
    if val > 0 then
        umg.call("lootplot:moneyAdded", fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:moneySubtracted", fromEnt, val)
    end
    lp.setMoney(fromEnt, val)
end
function lp.setMoney(fromEnt, x)
    lp.overrides.setMoney(fromEnt, x)
    umg.call("lootplot:setMoney", fromEnt, x)
end
function lp.addMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyMoney(fromEnt, x)
end
function lp.subtractMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyMoney(fromEnt, -x)
end

function lp.getMoney(ent)
    return lp.overrides.getMoney(ent)
end

end







local setSlotTc = typecheck.assert("ppos", "entity")

function lp.setSlot(ppos, slotEnt)
    -- directly sets a slot.
    -- (If a previous slot existed, destroy it.)
    setSlotTc(ppos, slotEnt)
    local prevEnt = lp.posToItem(ppos)
    if prevEnt then
        lp.destroy(prevEnt)
    end
    ppos.plot:setSlot(ppos.slot, slotEnt)
    ptrack.set(slotEnt, ppos)
end










--[[
    Movement of items:
]]
local ENT = "entity"

lp.detachItem = RPC("lootplot:detachItem", {ENT}, function(item)
    -- removes an entity from a plot. position info is nilled.
    local ppos = ptrack.get(item)
    local slot = ppos and lp.posToItem(ppos)
    if (not slot) or (slot.item ~= item) then
        return
    end
    -- OK: Item is upon the slot, we just need to remove it.
    slot.item = nil
    ptrack.set(item, nil)
end)


lp.attachItem = RPC("lootplot:attachItem", {ENT,ENT}, function(item, slotEnt)
    assert(not ptrack.get(item), "Item attached somewhere else")
    local ppos = lp.getPos(slotEnt)
    if umg.exists(slotEnt.item) then
        -- if item already exists: Destroy it and overwrite.
        lp.destroy(slotEnt.item)
    end
    slotEnt.item = item
    ptrack.set(item, ppos)
end)




local function ensureSlot(slotEnt_or_ppos)
    --[[
        Takes a slotEnt OR ppos,
        and returns a slotEnt.

        If anything is invalid, melts.
    ]]
    local ppos
    if ptrack.get(slotEnt_or_ppos) then
        -- its a slotEnt!
        ppos = lp.getPos(slotEnt_or_ppos)
    else
        ppos = slotEnt_or_ppos
    end

    local slotEnt = lp.posToSlot(ppos)
    if not slotEnt then
        umg.melt("Invalid slot-entity (or position) for slot!", 3)
    end
    return slotEnt
end


function lp.moveItem(item, slotEnt_or_ppos)
    -- moves an item to a position
    assert(server, "?")
    local slotEnt = ensureSlot(slotEnt_or_ppos)
    lp.detachItem(item)
    lp.attachItem(item, slotEnt)
end


local ent2Tc = typecheck.assert("entity", "entity")
function lp.swapItems(item1, item2)
    ent2Tc(item1, item2)
    local slot1, slot2 = lp.posToSlot(lp.getPos(item1)), lp.posToSlot(lp.getPos(item2))
    assert(slot1 and slot2, "Cannot swap nil-position")
    lp.detachItem(item1)
    lp.detachItem(item2)
    lp.attachItem(item1, slot2)
    lp.attachItem(item2, slot1)
end



function lp.activate(ent)
    if ent.onActivate then
        ent:onActivate()
    end
    umg.call("lootplot:entityActivated", ent)
    if ent.item then
        lp.activate(ent.item)
    end
end


function lp.destroy(ent)
    assert(server,"?")
    if umg.exists(ent) then
        ptrack.set(ent, nil)
        health.kill(ent)
    end
end


function lp.sellItem(ppos)
    -- sells the item at `ppos`
    umg.melt("nyi")
end

function lp.rotate(ent, angle)
    -- TODO.
    -- rotates `ent` by an angle.
    --  ent can be a slot OR an item
end

function lp.clone(ent)
    local cloned = ent:clone()
    --[[
        TODO: emit events here
    ]]
    return cloned
end

function lp.rerollItem(slotEnt_or_ppos)
    local slotEnt = ensureSlot(slotEnt_or_ppos)
    local ppos = lp.getPos(slotEnt)
    local itemEnt = lp.posToItem(ppos)
    -- destroy item,
    lp.destroy(itemEnt) 
    -- then, create a new item:
end

function lp.trySpawnItem(ppos, itemEType)
    local slotEnt = lp.posToSlot(ppos)
    local preItem = lp.posToItem(ppos)
    if slotEnt and (not preItem) then
        lp.forceSpawnItem(ppos, itemEType)
    end
end

function lp.forceSpawnItem(ppos, itemEType)
    local slotEnt = lp.posToSlot(ppos)
    assert(slotEnt, "forceSpawnItem requires a slot!")
    local itemEnt = itemEType()
    lp.attachItem(itemEnt, slotEnt)
    return itemEnt
end



function lp.removeAugment(ent, augment)
    umg.melt("nyi")
end
function lp.addAugment(ent, augment, val)
    umg.melt("nyi")
end





local strTabTc = typecheck.assert("string", "table")

function lp.defineItem(name, itemType)
    strTabTc(name, itemType)
    return umg.defineEntityType(name, itemType)
end

function lp.defineSlot(name, slotType)
    strTabTc(name, slotType)
    umg.defineEntityType(name, slotType)
end





lp.constants = {
    WORLD_SLOT_DISTANCE = 26, -- distance slots are apart in the world.
    PIPELINE_DELAY = 0.2
}





umg.expose("lp", lp)

return lp

