
--[[

Global api helper methods.

]]

local ptrack = require("shared.internal.positionTracking")



local lp = {}


lp.PPos = require("shared.PPos")


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
    game service:

    It's expected that custom gamemodes override the `Game` object.
]]
do
lp.Game = require("shared.Game")


local currentGame = nil

function lp.startGame(game)
    assert(server,"?")
    assert(not currentGame, "(Attempted to start a new game; must refresh server)")
    assert(lp.Game:isInstance(game), "Needs to be instance of `Game`")
    currentGame = game
    currentGame:start()
end

function lp.getGame()
    -- gets the current game context
    return currentGame
end

end



--[[
    Money/point services:
]]
do
local money = require("shared.services.money")
local points = require("shared.services.points")

lp.setMoney = money.setMoney
lp.setPoints = money.setPoints

lp.addMoney, lp.subtractMoney = money.addMoney, money.subtractMoney
lp.addPoints, lp.subtractPoints = points.addPoints, points.subtractPoints

function lp.getMoney(ent)
    return currentGame:getMoney(ent)
end
function lp.getPoints(ent)
    return currentGame:getPoints(ent)
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

        If anything is invalid, throws error.
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
        error("Invalid slot-entity (or position) for slot!", 3)
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
    --[[
        todo:
        this should almost definitely be an RPC
    ]]
end


function lp.destroy(ent)
    assert(server,"?")
    if umg.exists(ent) then
        ptrack.set(ent, nil)
        health.kill(ent)
    end
end


function lp.sellItem(ent)
    error("nyi")
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
    local slotEnt = lp.posToItem(ppos)
    if slotEnt then
        local itemEnt = lp.spawn(itemEType)
        lp.attachItem(itemEnt, slotEnt)
        return itemEnt
    end
end



umg.expose("lp", lp)

return lp

