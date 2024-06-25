---@meta

lp = {}

---@param ppos lootplot.PPos
---@param func fun()
function lp.queue(ppos, func)
end

---@param ppos lootplot.PPos
---@param time number
function lp.wait(ppos, time)
end

---@type lootplot.Bufferer|fun():lootplot.Bufferer
lp.Bufferer = require("server.Bufferer")
---@type lootplot.PPos|fun(args:{slot:integer,plot:lootplot.Plot,rotation?:number}):lootplot.PPos
lp.PPos = require("shared.PPos")
---@type lootplot.Plot|fun(ownerEnt:Entity,width:integer,height:integer):lootplot.Plot
lp.Plot = require("shared.Plot")

---@param x any
function lp.posTc(x)
end

---@param ppos lootplot.PPos
---@return lootplot.SlotEntity?
function lp.posToSlot(ppos)
end

---@param ppos lootplot.PPos
function lp.posToItem(ppos)
end

---@param slotEnt lootplot.SlotEntity
---@return lootplot.ItemEntity?
function lp.slotToItem(slotEnt)
end

---@param ent lootplot.LayerEntity
---@return lootplot.PPos?
function lp.getPos(ent)
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

local function assertServer()
    if not server then
        umg.melt("This can only be called on client-side!", 3)
    end
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

--[[
todo
do we need this function?
we could rename it to addItem....?
and then expose a detachItem function
]]
---@param item lootplot.ItemEntity
---@param slotEnt_or_ppos lootplot.SlotEntity|lootplot.PPos
function lp.moveItem(item, slotEnt_or_ppos)
end

---@param item1 lootplot.ItemEntity
---@param item2 lootplot.ItemEntity
function lp.swapItems(item1, item2)
end


---@param ent Entity
---@return boolean
function lp.canActivateEntity(ent)
end

---@param ent Entity
function lp.activateEntity(ent)
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

---@param itemEnt lootplot.ItemEntity
function lp.rerollItem(itemEnt)
end

---@param ppos lootplot.PPos
---@param itemEType fun():lootplot.ItemEntity
function lp.trySpawnItem(ppos, itemEType)
end

---@param ppos lootplot.PPos
---@param itemEType fun():lootplot.ItemEntity
---@return lootplot.ItemEntity
function lp.forceSpawnItem(ppos, itemEType)
end

function lp.removeAugment(ent, augment)
end

function lp.addAugment(ent, augment, val)
end

---@param name string
---@param itemType table<string, any>
function lp.defineItem(name, itemType)
end

---@param name string
---@param slotType table<string, any>
function lp.defineSlot(name, slotType)
end

lp.constants = {}
---@type integer
lp.constants.WORLD_SLOT_DISTANCE = 26
---@type number
lp.constants.PIPELINE_DELAY = 0.2

return lp
