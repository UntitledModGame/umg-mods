

--[[

A fixed-size Grid object.

IMPORTANT NOTE:
(x,y) coords are ZERO-indexed,
but (i) indexes are ONE-indexed.

(The reason it's 1-indexed is so it works better with lua arrays)


]]

local Class = require("shared.Class")


local Grid = Class("objects:Grid")


local initTc = typecheck.assert("number", "number")
function Grid:init(width, height)
    initTc(width, height)
    self.width = width
    self.height = height
    self.size = width * height

    self.grid = {} -- just a flat array
end


local function assertInRange(self, i)
    if (i < 1) or (i > self.size) then
        error(("Coord index out of range:\nwidth=%d, height=%d, i=%d"):format(self.width, self.height, i), 3)
    end
end


local number2Tc = typecheck.assert("number", "number")
function Grid:set(x,y, val)
    number2Tc(x,y)
    local i = self:coordsToIndex(x,y)
    assertInRange(self, i)
    self.grid[i]=val
end


function Grid:get(x,y)
    number2Tc(x,y)
    local i = self:coordsToIndex(x,y)
    return self.grid[i]
end



function Grid:coordsToIndex(x, y)
    -- converts (x,y) coordinates --> index
    -- BIG WARNING!!! indexes are ONE-INDEXED!!
    local index = y*self.height + x + 1 -- plus-1 for 1-based indexing.
    return index
end


function Grid:contains(x, y)
    return (x>=0) and (y>=0) and (x<self.width) and (y<self.height)
end


function Grid:indexToCoords(index)
    -- converts index  --->  (x,y) coordinates.
    -- BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!
    index = index - 1
    local x = index % self.width
    local y = math.floor(index / self.width)
    return x, y
end


local funcTc = typecheck.assert("table", "function")
function Grid:foreach(func)
    funcTc(self, func)
    for x=0, self.width-1 do
        for y=0, self.height-1 do
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
end


return Grid


