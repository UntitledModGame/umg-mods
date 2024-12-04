

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.

]]

local worldPlotEnts = umg.group("plot", "x", "y")




local function updateItem(itemEnt, dvec)
    assert(dvec, "?")
    local x, y = dvec.x, dvec.y

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
end


local function updateSlot(slotEnt, dvec)
    assert(dvec, "?")
    slotEnt.x, slotEnt.y = dvec.x, dvec.y
end


local ITEM_LAYER = "item"
local SLOT_LAYER = "slot"

---@type table<lootplot.PPos, spatial.DimensionVector>
local DVEC_CACHE = setmetatable({}, {__mode = "k"})


---@param ppos lootplot.PPos
local function updatePlotReal(ppos)
    local plot = ppos:getPlot()
    -- we have inlined this a bit, so its simpler.
    -- (We had perf issues with this code, since its EXTREMELY HOT.)
    ---@cast ppos lootplot.PPos
    local x,y = ppos:getCoords()
    local dvec = DVEC_CACHE[ppos]
    if not dvec then
        dvec = plot:pposToWorldCoords(ppos)
        DVEC_CACHE[ppos] = dvec
    end

    local itemEnt = plot:get(ITEM_LAYER, x,y)
    if itemEnt then
        -- dvec = ppos:getWorldPos()
        updateItem(itemEnt, dvec)
    end

    local slotEnt = plot:get(SLOT_LAYER, x,y)
    if slotEnt then
        -- dvec = dvec or ppos:getWorldPos()
        updateSlot(slotEnt, dvec)
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

