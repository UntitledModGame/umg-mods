
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

    ownerEnt.plot = self

    self.owner = ownerEnt
    self.grid = objects.Grid(width,height)
end



function Plot:setSlot(index, slotEnt)
    self.grid:setIndex(index, slotEnt)
    if server then
        if slotEnt then
            server.broadcast("lootplot:setPlotSlot", index, slotEnt)
        else
            server.broadcast("lootplot:clearPlotSlot", index)
        end
    end
end

if client then
    client.on("lootplot:setPlotSlot", function(x,y, ent)
        ent.plot:set(x,y,ent)
    end)
    client.on("lootplot:clearPlotSlot", function(x,y, ent)
        ent.plot:set(x,y,nil)
    end)
end



function Plot:getSlot(index)
    local x,y = self.grid:indexToCoords(index)
    local e = self.grid:get(x,y)
    if umg.exists(e) then
        return e
    end
end



function Plot:setItem(index, itemEnt)
    local slot = self:getSlot(index)
    if slot and canAdd(slot, itemEnt) then
        
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

