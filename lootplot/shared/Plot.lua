
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Pipeline = require("shared.Pipeline")

---@class lootplot.Plot: objects.Class
local Plot = objects.Class("lootplot:Plot")

local ptrack = require("shared.internal.positionTracking")




local plotTc = typecheck.assert("entity", "number", "number")
---@param ownerEnt Entity
---@param width integer
---@param height integer
function Plot:init(ownerEnt, width, height)
    plotTc(ownerEnt, width, height)

    ownerEnt.plot = self

    if server then
        self.pipeline = Pipeline()
    end

    -- needed for syncing
    self._cachedIsPipelineRunning = false

    self.ownerEnt = ownerEnt

    self.grid = objects.Grid(width,height) -- dummy grid; contains nothing.

    self.fogColor = objects.Color(1,1,1)

    self.layers = {
        --[[
            todo: Do we want custom Layer objects here,
            instead of Grid objects?
        ]]
        ["slot"] = objects.Grid(width,height),
        ["item"] = objects.Grid(width,height),

        -- ents that are part of the world itself
        -- (ie text, bosses, etc)
        ["world"] = objects.Grid(width,height)
        -- ... can define custom ones too!
    }
    self.layerKeys = {}

    for k in pairs(self.layers) do
        self.layerKeys[#self.layerKeys+1] = k
    end
    table.sort(self.layerKeys)

    ---@type table<string, objects.Grid>
    self.fogs = {} -- Note: Grid value false means revealed, true means hidden.

    -- entities that we have already seen.
    --[[
        NOTE:
        `seenEntities` doesnt do anything rn,
        but if we want our code to be a bit more defensive in the future,
        we can use this to check for duplicates.

        (Can be used for asserting that the same entity doesnt exist in
            multiple slots)
    ]]
    self.seenEntities = {--[[
        [ent] = boolean
    ]]}

    self.width, self.height = width, height

    ---[i] = ppos
    ---@type table<integer, lootplot.PPos>
    self.pposCache = {}
end

function Plot:getDimensions()
    return self.width, self.height
end




local INDEX = "number"
local ENT = "entity"
local LAYER = "string"
local BOOL = "boolean"

umg.definePacket("lootplot:setPlotEntry", {typelist = {ENT, INDEX, ENT}})
umg.definePacket("lootplot:clearPlotEntry", {typelist = {ENT, INDEX, LAYER}})
umg.definePacket("lootplot:fogReveal", {typelist = {ENT, "string", INDEX, BOOL}})


local setTc = typecheck.assert("number", "number", "entity")

---@param x integer
---@param y integer
---@param ent lootplot.LayerEntity needs ent.layer comp
function Plot:set(x, y, ent)
    --[[
        ent needs ent.layer comp
    ]]
    setTc(x,y,ent)
    assert(ent:isSharedComponent("layer"))
    --[[
        TODO: Should we guard against multiple attachment???
        hmmm... 
        Future mods may need this bahaviour
    ]]
    assert(not ptrack.get(ent), "attached somewhere else")

    local grid = self.layers[ent.layer]
    local index = self:coordsToIndex(x,y)
    grid:set(x,y, ent)
    ptrack.set(ent, self:getPPos(x,y))
    if server then
        local plotEnt = self.ownerEnt
        server.broadcast("lootplot:setPlotEntry", plotEnt, index, ent)
    end
end


local clearTc = typecheck.assert('number', 'string')
---@param index integer
---@param layer string layer name
function Plot:clear(index, layer)
    clearTc(index, layer)
    local x,y = self.grid:indexToCoords(index)
    local grid = self.layers[layer]
    grid:set(x,y, nil)
    if server then
        local plotEnt = self.ownerEnt
        assert(self.layers[layer], "invalid layer")
        server.broadcast("lootplot:clearPlotEntry", plotEnt, index, layer)
    end
end



umg.definePacket("lootplot:setPipelineRunningBool", {typelist = {ENT, BOOL}})

---@param dt number
function Plot:tick(dt)
    assert(server,"?")
    self.pipeline:tick(dt)
    local oldIsRunnin = self._cachedIsPipelineRunning
    local isRunnin = self:isPipelineRunning()
    if oldIsRunnin ~= isRunnin then
        server.broadcast("lootplot:setPipelineRunningBool", self.ownerEnt, isRunnin)
        self._cachedIsPipelineRunning = isRunnin
    end
end


if client then

client.on("lootplot:setPlotEntry", function(plotEnt, index, ent)
    local plot = plotEnt.plot
    local x,y = plot:indexToCoords(index)
    plot:set(x, y, ent)
end)
client.on("lootplot:clearPlotEntry", function(plotEnt, index, layer)
    plotEnt.plot:clear(index, layer)
end)

client.on("lootplot:setPipelineRunningBool", function(plotEnt, bool)
    plotEnt.plot._cachedIsPipelineRunning = bool
end)

end




function Plot:getOwnerEntity()
    return self.ownerEnt
end


---@param layer string
---@param x integer
---@param y integer
---@return Entity?
function Plot:get(layer, x,y)
    -- Note: getTc is too slow. Test the args manually instead.
    -- getTc(layer, x,y)
    assert(type(layer) == "string", "string expected for layer")
    assert(type(x) == "number", "number expected for x")
    assert(type(y) == "number", "number expected for y")

    local grid = self.layers[layer]
    if not grid then
        error("Invalid layer: " .. tostring(layer))
    end
    assert(self.grid:contains(x,y), "out of bounds!")
    local ent = grid:get(x,y)
    if umg.exists(ent) then
        return ent
    end
end


function Plot:getPPosFromSlotIndex(index)
    local ppos = self.pposCache[index]

    if not ppos then
        ppos = lp.PPos({slot = index, plot = self})
        self.pposCache[index] = ppos
    end

    assert(ppos:getSlotIndex() == index, "Don't mutate PPos Objects!!!")
    return ppos
end

---@param x number
---@param y number
---@return lootplot.PPos
function Plot:getPPos(x,y)
    local index = self:coordsToIndex(x,y)
    return self:getPPosFromSlotIndex(index)
end

function Plot:isInBounds(x,y)
    return self.grid:contains(x,y)
end



function Plot:getCenterPPos()
    return self:getPPos(math.floor(self.width / 2), math.floor(self.height / 2))
end



---@param x integer
---@param y integer
---@return lootplot.SlotEntity?
function Plot:getSlot(x, y)
    return self:get("slot", x, y)
end

---@param x integer
---@param y integer
---@return lootplot.ItemEntity?
function Plot:getItem(x, y)
    return self:get("item", x,y)
end

---@param x1 integer
---@param x2 integer
---@param y1 integer
---@param y2 integer
---@param func fun(ppos:lootplot.PPos)
function Plot:foreachInArea(x1, y1, x2, y2, func)
    local grid = self.grid
    return grid:foreachInArea(x1, y1, x2, y2, function(_val,x,y)
        local ppos = self:getPPos(x, y)
        func(ppos)
    end)
end


---@param slotIndex integer
---@return integer,integer
function Plot:indexToCoords(slotIndex)
    return self.grid:indexToCoords(slotIndex)
end

---@param x integer
---@param y integer
---@return integer
function Plot:coordsToIndex(x,y)
    return self.grid:coordsToIndex(x,y)
end


---runs a function within a plot, buffered.
---@param fn fun(...:any)
---@param ... any
function Plot:queue(fn, ...)
    self.pipeline:push(fn, ...)
end

---@param time number
function Plot:wait(time)
    local mult = umg.ask("lootplot:getPipelineDelayMultiplier", self) or 1
    self.pipeline:wait(time * mult)
end




---loops over all of the plot, including empty slots
---@param func fun(ppos:lootplot.PPos)
function Plot:foreach(func)
    for y=0, self.height-1 do
        for x=self.width-1, 0, -1 do
            local ppos = self:getPPos(x, y)
            func(ppos)
        end
    end
end

---loops over all slot-entities in plot
---@param func fun(ent:lootplot.SlotEntity,ppos:lootplot.PPos)
function Plot:foreachSlot(func)
    self:foreach(function(ppos)
        local slotEnt = lp.posToSlot(ppos)
        if slotEnt then
            func(slotEnt, ppos)
        end
    end)
end

---loops over all item-entities in plot
---@param func fun(ent:lootplot.ItemEntity,ppos:lootplot.PPos)
function Plot:foreachItem(func)
    self:foreach(function(ppos)
        local itemEnt = lp.posToItem(ppos)
        if itemEnt then
            func(itemEnt, ppos)
        end
    end)
end

---@param func fun(ent: Entity, ppos:lootplot.PPos, layer:string)
function Plot:foreachLayerEntry(func)
    self:foreach(function(ppos)
        local x,y = self:indexToCoords(ppos:getSlotIndex())
        for _, layer in ipairs(self.layerKeys) do
            local ent = self:get(layer, x,y)
            if ent then
                func(ent, ppos, layer)
            end
        end
    end)
end


---returns plot-position as a dimensionVector
---@param ppos lootplot.PPos
---@return number x, number y, string? dimension, number? z
function Plot:pposToWorldCoords(ppos)
    local plotEnt = self.ownerEnt
    assert(plotEnt.x and plotEnt.y, "Cannot get world position of a Plot when owner ent doesn't have x,y components")
    local ix,iy = ppos:getCoords()
    local slotDist = lp.constants.WORLD_SLOT_DISTANCE
    local x = plotEnt.x + ix*slotDist
    local y = plotEnt.y + iy*slotDist
    local z = plotEnt.z or 0
    return x,y, plotEnt.dimension, z
end


---gets the closest ppos to a (x,y) coord pair.
---
---**NOTE:**
---If the (x,y) coords is out of bounds, 
---it will STILL return the closest match!
---@param worldX number
---@param worldY number
---@return lootplot.PPos
function Plot:getClosestPPos(worldX, worldY)
    local plotEnt = self.ownerEnt
    assert(plotEnt.x and plotEnt.y, "plot-owner-entity needs world position!")
    local slotDist = lp.constants.WORLD_SLOT_DISTANCE
    local ix = math.round((worldX/slotDist) - plotEnt.x)
    local iy = math.round((worldY/slotDist) - plotEnt.y)

    local grid = self.grid
    ix = math.clamp(ix, 0, grid.width-1)
    iy = math.clamp(iy, 0, grid.height-1)
    return self:getPPos(ix, iy)
end


function Plot:isPipelineRunning()
    if server then
        return not self.pipeline:isEmpty()
    else
        -- pipeline is a server-side object! 
        -- So we gotta use our synced value
        return self._cachedIsPipelineRunning
    end
end



local fogTc = typecheck.assert("table", "string")

---@param ppos lootplot.PPos
---@param team string
function Plot:isFogRevealed(ppos, team)
    fogTc(ppos, team)
    assert(ppos:getPlot() == self)

    local grid = self.fogs[team]
    if grid then
        return not grid:get(ppos:getCoords())
    end

    return true
end

if server then

---Availability: **Server**
---@param ppos lootplot.PPos
---@param team string
---@param reveal boolean
function Plot:setFogRevealed(ppos, team, reveal)
    fogTc(ppos, team)
    assert(ppos:getPlot() == self)

    local grid = self.fogs[team]
    if not grid then
        grid = objects.Grid(self.width, self.height)
        self.fogs[team] = grid
    end

    local x, y = ppos:getCoords()
    local old = not grid:get(x, y)
    grid:set(x, y, not reveal)

    if old ~= reveal then
        local hasFog = not reveal
        umg.call("lootplot:plotFogChanged", self, team, ppos, hasFog)
        server.broadcast("lootplot:fogReveal", self.ownerEnt, team, ppos:getSlotIndex(), reveal)
    end
end

function Plot:removeDeletedEntities()
    self:foreach(function(ppos)
        local px, py = ppos:getCoords()
        for layer, grid in pairs(self.layers) do
            local ent = grid:get(px, py)
            if ent and not umg.exists(ent) then
                umg.log.trace("ppos "..tostring(ppos), ": entity "..tostring(ent).." was deleted at layer ".. layer .. ". Clearing the grid...")
                grid:set(px, py, nil)
            end
        end
    end)
end

else

client.on("lootplot:fogReveal", function(plotEnt, team, index, reveal)
    local plot = plotEnt.plot
    local grid = plot.fogs[team]
    if not grid then
        grid = objects.Grid(plot.width, plot.height)
        plot.fogs[team] = grid
    end

    local ppos = assert(plot:getPPosFromSlotIndex(index))
    local hasFog = not reveal
    umg.call("lootplot:plotFogChanged", plot, team, ppos, hasFog)
    local x, y = plot:indexToCoords(index)
    grid:set(x, y, not reveal)
end)

end


---@cast Plot +fun(ownerEnt:Entity,width:integer,height:integer):lootplot.Plot
return Plot

