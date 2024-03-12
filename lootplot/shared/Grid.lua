

local Grid = objects.Class("lootplot:Grid")



local gridTc = typecheck.assert("number", "number")
function Grid:init(width, height)
    gridTc(width, height)
    self.width = width
    self.height = height
end


function Grid:clone()
    error("todo")
end



function Grid:set(x,y, value)
    error("todo")
end

function Grid:get(x,y)
    return error("todo")
end






local funcTc = typecheck.assert("table", "function")

function Grid:filter(func)
    funcTc(self, func)
    local grid = Grid()
    --[[
        TODO
    ]]
    return grid
end


function Grid:map(func)
    funcTc(self, func)
    local grid = Grid()
    --[[
        TODO
    ]]
    return grid
end



return Grid

