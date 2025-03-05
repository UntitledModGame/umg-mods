
local Class = require("shared.Class")

--[[

A fixed-size Grid object.

**IMPORTANT NOTE**:
(x,y) coords are ZERO-indexed,
but (i) indexes are ONE-indexed.

(The reason it's 1-indexed is so it works better with lua arrays)


]]
---Availability: Client and Server
---@class objects.Grid: objects.Class
local Grid = Class("objects:Grid")


local initTc = typecheck.assert("number", "number")
---@param width integer
---@param height integer
function Grid:init(width, height)
    initTc(width, height)
    self.width = width
    self.height = height
    self.size = width * height

    self.grid = {} -- just a flat array
    for i=1, self.size do
        -- fill with false values. This avoids nasty serialization issues
        -- (TODO: we probably should fix umg.serialize?)
        self.grid[i] = false
    end
end


if false then
    ---Availability: Client and Server
    ---@param width integer
    ---@param height integer
    ---@return objects.Grid
    function Grid(width, height) end ---@diagnostic disable-line: cast-local-type, missing-return
end


---@param self objects.Grid
---@param i integer
local function assertInRange(self, i)
    if (i < 1) or (i > self.size) then
        umg.melt(("Coord index out of range:\nwidth=%d, height=%d, i=%d"):format(self.width, self.height, i), 3)
    end
end


local number2Tc = typecheck.assert("number", "number")

---@param x integer
---@param y integer
---@param val any
function Grid:set(x,y, val)
    number2Tc(x,y)
    local i = self:coordsToIndex(x,y)
    assertInRange(self, i)
    self.grid[i]=val
end

---@param x integer
---@param y integer
---@return any
function Grid:get(x,y)
    number2Tc(x,y)
    local i = self:coordsToIndex(x,y)
    return self.grid[i]
end



---converts (x,y) coordinates --> index
---
---**BIG WARNING!!! indexes are ONE-INDEXED!!**
---@param x integer
---@param y integer
---@return integer
function Grid:coordsToIndex(x, y)
    -- converts (x,y) coordinates --> index
    -- BIG WARNING!!! indexes are ONE-INDEXED!!
    local index = y*self.width + x + 1 -- plus-1 for 1-based indexing.
    return index
end

---@param x integer
---@param y integer
---@return boolean
function Grid:contains(x, y)
    return (x>=0) and (y>=0) and (x<self.width) and (y<self.height)
end

---converts index  --->  (x,y) coordinates.
---
---**BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!**
---@param index integer
---@return integer,integer
function Grid:indexToCoords(index)
    -- converts index  --->  (x,y) coordinates.
    -- BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!
    index = index - 1
    local x = index % self.width
    local y = math.floor(index / self.width)
    return x, y
end



local funcTc = typecheck.assert("table", "function")

---@param func fun(value:any,x:integer,y:integer)
function Grid:foreach(func)
    funcTc(self, func)
    for x=0, self.width-1 do
        for y=0, self.height-1 do
            local v = self:get(x,y)
            func(v, x,y)
        end
    end
end



local foreachInAreaTc = typecheck.assert(
    "table", 
    "number", "number", "number", "number", 
    "function"
)

---x and y position are both inclusive
---@param x1 integer
---@param x2 integer
---@param y1 integer
---@param y2 integer
---@param func fun(value:any,x:integer,y:integer)
function Grid:foreachInArea(x1,y1, x2,y2, func)
    foreachInAreaTc(self, x1,y1, x2,y2, func)
    for x=x1, x2 do
        for y=y1, y2 do
            local v = self:get(x,y)
            func(v, x,y)
        end
    end
end



local TEST = false
if TEST then
    local g = Grid(10, 10)
    for i=1, 100 do
        local x,y = g:indexToCoords(i)
        assert(i == g:coordsToIndex(x,y),"?")
    end

    local function fillWithRandom(grid)
        local sze = grid.width*grid.height
        for i=1, sze do
            if math.random() < 0.5 then
                local x,y = grid:indexToCoords(i)
                grid:set(x,y, 42)
            end
        end
    end

    -- test serialization:
    -- (Zomebody found lootplot bug, looked sus with nil values?)
    -- we might need to flood the array with `false` instead of nils
    for i=1, 80000 do
        local g1 = Grid(10,10)
        fillWithRandom(g1)

        local g2 = umg.deserialize(umg.serialize(g1))
        g1:foreach(function(value, x, y)
            if value ~= g2:get(x,y) then
                print(umg.inspect(g2.grid), umg.inspect(g1.grid))
                umg.melt("TEST FAILED!!")
            end
        end)
    end
end


return Grid
