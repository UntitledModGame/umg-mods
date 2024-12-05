

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.

]]

local worldPlotEnts = umg.group("plot", "x", "y")




local function updateItem(itemEnt, x,y,dim)
    -- the target position the item should lerp to.
    local targetX, targetY = umg.ask("lootplot:getItemTargetPosition", itemEnt)
    if targetX then
        itemEnt.targetX = targetX
        itemEnt.targetY = targetY
    else
        itemEnt.targetX = x
        itemEnt.targetY = y
    end

    if not (itemEnt.x and itemEnt.y) then
        itemEnt.x = x
        itemEnt.y = y
    end
    itemEnt.dimension = dim
end


local function updateSlot(slotEnt, x,y,dim)
    slotEnt.x, slotEnt.y = x,y
    slotEnt.dimension = dim
end


local ITEM_LAYER = "item"
local SLOT_LAYER = "slot"


---@param ppos lootplot.PPos
local function updatePlotReal(ppos)
    local plot = ppos:getPlot()
    -- we have inlined this a bit, so its simpler.
    -- (We had perf issues with this code, since its EXTREMELY HOT.)
    ---@cast ppos lootplot.PPos
    local ix,iy = ppos:getCoords()
    local x,y,dim
    local itemEnt = plot:get(ITEM_LAYER, ix,iy)
    if itemEnt then
        x,y,dim = ppos:getWorldPos()
        updateItem(itemEnt, ppos:getWorldPos())
    end

    local slotEnt = plot:get(SLOT_LAYER, ix,iy)
    if slotEnt then
        if not x then
            x,y,dim = ppos:getWorldPos()
        end
        updateSlot(slotEnt, x,y,dim)
    end
end

---comment
---@param plot lootplot.Plot
local function updatePlot(plot)
    return plot:foreach(updatePlotReal)
end


umg.on("@tick", function(dt)
    for _, plotEnt in ipairs(worldPlotEnts) do
        updatePlot(plotEnt.plot)
    end
end)



local targetEnts = umg.group("targetX", "targetY", "x", "y")

local SPEED = 8

umg.on("@update", function(dt)
    for _, ent in ipairs(targetEnts) do
        local dx,dy = ent.targetX-ent.x, ent.targetY-ent.y
        ent.x = ent.x + dt*dx*SPEED
        ent.y = ent.y + dt*dy*SPEED
    end
end)

