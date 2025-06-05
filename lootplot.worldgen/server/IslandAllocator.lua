---@class lootplot.worldgen.IslandAllocator: objects.Class
local IslandAllocator = objects.Class("lootplot.worldgen:IslandAllocator")

--[[
All in all, the `Preallocator` is just a grid of booleans.
After calling `:generateIslands()`, the `Preallocator` takes the grid of booleans, and converts it to a list of islands.

The `Preallocator` should provide methods for these things:
- Method to clear a grid around CIRCLE-2 shape of any ppos with any layer-ent
- Method to set/unset a value
- Method to `:map` x,y coords to true/false
- `:generateIslands()` to build islands

local p = IslandAllocator(plot)

-- setting/defining terrain
p:map(f)
p:set(ppos, true)
p:get(ppos)

-- restrict:
local radius = 1
p:clearNearbyEntities(radius)

-- flood/build:
local islands = p:generateIslands()
]]


---@param plot lootplot.Plot
function IslandAllocator:init(plot)
    self.width, self.height = plot:getDimensions()
    self.plot = plot
    self.grid = objects.Grid(self.width, self.height)
    self.grid:foreach(function(_, x, y)
        return self.grid:set(x, y, false)
    end)
end

if false then
    ---@param plot lootplot.Plot
    ---@return lootplot.worldgen.IslandAllocator
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function IslandAllocator(plot) end
end

---@param func fun(ppos:lootplot.PPos,oldval:boolean):boolean
function IslandAllocator:map(func)
    assert(objects.isCallable(func), "missing function")

    self.grid:foreach(function(value, x, y)
        self.grid:set(x, y, not not func(self.plot:getPPos(x, y), value))
    end)
end

---@param ppos lootplot.PPos
function IslandAllocator:get(ppos)
    return not not self.grid:get(ppos:getCoords())
end

---@param ppos lootplot.PPos
---@param val boolean
function IslandAllocator:set(ppos, val)
    local x, y = ppos:getCoords()
    return self.grid:set(x, y, not not val)
end


---Removes any island-land that is too close to an entity that currently
---exists in the plot.
---(In a circle, specified by radius)
---
---This ensures that the generated islands don't overwrite any existing slots/items.
---@param radius? integer The "range" at which the islands are culled from. Default=1
function IslandAllocator:cullNearbyIslands(radius)
    radius = radius or 1
    return self.plot:foreachLayerEntry(function(_, basePPos)
        local r2 = (radius + 0.5) ^ 2
        for y = -radius, radius do
            for x = -radius, radius do
                if x * x + y * y <= r2 then
                    local ppos = basePPos:move(x, y)
                    if ppos then
                        local px, py = ppos:getCoords()
                        self.grid:set(px, py, false)
                    end
                end
            end
        end
    end)
end

function IslandAllocator:generateIslands()
    local islandGroup = objects.Grid(self.width, self.height) -- contains group id
    ---@type lootplot.PPos[][]
    local islands = {}

    -- Pass 3: Flood fill unmarked islands
    local function consider(stack, x, y)
        if self.grid:get(x, y) and (not islandGroup:get(x, y)) then
            stack[#stack+1] = islandGroup:coordsToIndex(x, y)
        end
    end
    islandGroup:foreach(function(value, x, y)
        if not self.grid:get(x, y) then
            return
        end

        if not value or value == 0 then
            local island = {}
            islands[#islands+1] = island
            local groupId = #islands

            local stack = {islandGroup:coordsToIndex(x, y)}
            while #stack > 0 do
                local i = table.remove(stack)
                local px, py = islandGroup:indexToCoords(i)
                local ppos = self.plot:getPPos(px, py)
                island[#island+1] = ppos

                islandGroup:set(px, py, groupId)
                consider(stack, px - 1, py)
                consider(stack, px, py - 1)
                consider(stack, px + 1, py)
                consider(stack, px, py + 1)
            end
        end
    end)

    return islands
end

return IslandAllocator
