---@meta

lp = {}

---basic action-buffering, with 0 arguments for function.
---
---NOTE:  This function name is a bit confusing!!!
---    It doesn't actually add `func` to a queue;
---    it adds it to a LIFO stack.
---    I just think that `lp.queue` is a more sensible name than 
---        `lp.push` or `lp.buffer`
---@param ppos lootplot.PPos
---@param func fun()
function lp.queue(ppos, func)
end

function lp.wait(ppos, time)
end

lp.Bufferer = require("server.Bufferer")
---@type lootplot.PPos|fun(args:{slot:integer,plot:lootplot.Plot,rotation?:number}):lootplot.PPos
lp.PPos = require("shared.PPos")
---@type lootplot.Plot|fun(ownerEnt:Entity,width:integer,height:integer):lootplot.Plot
lp.Plot = require("shared.Plot")

---@param x any
function lp.posTc(x)
end

--[[
    Positioning:
]]
---@param ppos lootplot.PPos
---@return lootplot.SlotEntity?
function lp.posToSlot(ppos)
end

---@param ppos lootplot.PPos
---@return lootplot.ItemEntity?
function lp.posToItem(ppos)
end

---@param slotEnt lootplot.SlotEntity
---@return lootplot.ItemEntity?
function lp.slotToItem(slotEnt)
end

---@param ent Entity
---@return boolean
function lp.isSlotEntity(ent)
end

---@param ent Entity
---@return boolean
function lp.isItemEntity(ent)
end

---@param ent lootplot.LayerEntity
---@return lootplot.PPos?
function lp.getPos(ent)
end

---@param itemEnt lootplot.ItemEntity
function lp.itemToSlot(itemEnt)
end

--[[
    everything in this table must be overridden
    by some playable lootplot mod.
]]
lp.overrides = {}

function lp.overrides.setPoints(ent, x)
end

function lp.overrides.getPoints(ent)
end

function lp.overrides.setMoney(ent, x)
end

function lp.overrides.getMoney(ent)
end

---@param fromEnt Entity
---@param x number
function lp.setPoints(fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.addPoints(fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.subtractPoints(fromEnt, x)
end

---@param ent Entity
---@return number
function lp.getPoints(ent)
end

---@param fromEnt Entity
---@param x number
function lp.setMoney(fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.addMoney(fromEnt, x)
end

---@param fromEnt Entity
---@param x number
function lp.subtractMoney(fromEnt, x)
end

---@param ent Entity
---@return number
function lp.getMoney(ent)
end

---@param ppos lootplot.PPos
---@param slotEnt lootplot.SlotEntity
function lp.setSlot(ppos, slotEnt)
end

---This one needs valid slot but does not require item to be present.
---If item is not present, it acts as move.
---@param slotEnt1 lootplot.SlotEntity
---@param slotEnt2 lootplot.SlotEntity
function lp.swapItems(slotEnt1, slotEnt2)
end

---@param slot1 lootplot.SlotEntity
---@param slot2 lootplot.SlotEntity
---@return boolean
function lp.canSwap(slot1, slot2)
end

---@param ent Entity
---@return boolean
function lp.canActivateEntity(ent)
end

---@param ent Entity
function lp.tryActivateEntity(ent)
end

---@param ent Entity
function lp.forceActivateEntity(ent)
end


---@param pos lootplot.PPos
function lp.activate(pos)
end

---@param ent Entity
function lp.destroy(ent)
end

---@param ppos lootplot.ItemEntity
function lp.sellItem(ppos)
end

---@param ent lootplot.LayerEntity
---@param angle number
function lp.rotate(ent, angle)
end

---@generic T: EntityClass
---@param ent T
---@return T
function lp.clone(ent)
end

---@param ppos lootplot.PPos
---@param itemEType fun():lootplot.ItemEntity
---@return lootplot.ItemEntity?
function lp.trySpawnItem(ppos, itemEType)
end

---@param ppos lootplot.PPos
---@param itemEType fun():lootplot.ItemEntity
---@return lootplot.ItemEntity
function lp.forceSpawnItem(ppos, itemEType)
end


---@param name string
---@param itemType table<string, any>
function lp.defineItem(name, itemType)
end

---@param name string
---@param slotType table<string, any>
function lp.defineSlot(name, slotType)
end

---@param name string
function lp.defineTrigger(name)
end


---@param name string
---@param ent Entity
function lp.tryTriggerEntity(name, ent)
end

---@param name string
---@param ent Entity
function lp.forceTriggerEntity(name, ent)
end

---@param name string
---@param ent Entity
---@return boolean
function lp.canTrigger(name, ent)
end

---@param ent lootplot.ItemEntity|lootplot.SlotEntity
---@param clientId string
---@return boolean
function lp.canPlayerAccess(ent, clientId)
end

lp.constants = {}
---@type integer
lp.constants.WORLD_SLOT_DISTANCE = 26
---@type number
lp.constants.PIPELINE_DELAY = 0.2

---@type generation.Generator
lp.SLOT_GENERATOR = nil
---@type generation.Generator
lp.ITEM_GENERATOR = nil

return lp