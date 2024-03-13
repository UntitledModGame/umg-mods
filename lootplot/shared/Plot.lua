
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Plot = objects.Class("lootplot:Plot")



local gridTc = typecheck.assert("entity", "number", "number")
function Plot:init(ownerEnt, width, height)
    gridTc(width, height)
    self.owner = ownerEnt

    self.grid = objects.Grid(width,height)
end



function Plot:set(x,y, ent)
    self.grid[x][y] = ent
    if server then
        if ent then
            server.broadcast("looplot:setPlotSlot", x,y, ent)
        else
            server.broadcast("looplot:clearPlotSlot", x,y)
        end
    end
end

if client then
    client.on("looplot:setPlotSlot", function(x,y, ent)
        ent.grid:set(x,y,ent)
    end)
    client.on("looplot:clearPlotSlot", function(x,y, ent)
        ent.grid:set(x,y,nil)
    end)
end




function Plot:get(x,y)
    local e = self.grid[x][y]
    if umg.exists(e) then
        return e
    end
end







local funcTc = typecheck.assert("table", "function")

function Plot:filter(func)
    funcTc(self, func)
    local grid = Plot(self.width, self.height)
    for x=0, self.width-1 do
        for y=0, self.height-1 do
            local val = func(self:get(x,y), x, y)
            if val then
                grid:set(x,y, val)
            end
        end
    end
    return grid
end


function Plot:foreach(func)
    funcTc(self, func)
    for x=0, self.width-1 do
        for y=0, self.height-1 do
            func(self:get(x,y), x, y)
        end
    end
end



return Plot

