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
]]

---@param ppos lootplot.PPos
---@return boolean
local function returnFalse(ppos) return false end

---@param plot lootplot.Plot
function IslandAllocator:new(plot)
    self.width, self.height = plot:getDimensions()
    self.plot = plot
    self.mapper = returnFalse
    self.restrictRadius = 2
end

if false then
    ---@param plot lootplot.Plot
    ---@return lootplot.worldgen.IslandAllocator
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function IslandAllocator(plot) end
end

---@param func fun(ppos:lootplot.PPos):boolean
function IslandAllocator:map(func)
    self.mapper = assert(func, "missing function")
    return self
end

function IslandAllocator:setLayerClearRadius(radius)
    self.restrictRadius = math.max(radius or 1, 1)
    return self
end


function IslandAllocator:allocate()
    -- Value types:
    -- nil = not considered
    -- -1 = not allowed
    -- 0 = island in here but not categorized
    -- 1 and above = island in here, categorized
    local group = objects.Grid(self.width, self.height)
    ---@type lootplot.PPos[][]
    local islands = {}

    -- Pass 1: Analyze restricted pposes
    self.plot:foreachLayerEntry(function(_, basePPos)
        local r2 = (self.restrictRadius + 0.5) ^ 2
        for y = -self.restrictRadius, self.restrictRadius do
            for x = -self.restrictRadius, self.restrictRadius do
                if x * x + y * y <= r2 then
                    local ppos = basePPos:move(x, y)
                    if ppos then
                        local px, py = ppos:getCoords()
                        group:set(px, py, -1)
                    end
                end
            end
        end
    end)

    -- Pass 2: Generate islands
    group:foreach(function(value, x, y)
        if value ~= -1 then
            if self.mapper(self.plot:getPPos(x, y)) then
                group:set(x, y, 0)
            end
        end
    end)

    -- Pass 3: Flood fill unmarked islands
    local function consider(stack, x, y)
        if group:get(x, y) == 0 then
            stack[#stack+1] = group:coordsToIndex(x, y)
        end
    end
    group:foreach(function(value, x, y)
        if value == 0 then
            local island = {}
            islands[#islands+1] = island
            local groupId = #islands
            local stack = {group:coordsToIndex(x, y)}
            while #stack > 0 do
                local i = table.remove(stack)
                local ppos = self.plot:getPPos(group:indexToCoords(i))
                island[#island+1] = ppos

                group:set(x, y, groupId)
                consider(stack, x - 1, y)
                consider(stack, x, y - 1)
                consider(stack, x + 1, y)
                consider(stack, x, y + 1)
            end
        end
    end)

    return islands
end

return IslandAllocator
