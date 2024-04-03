
--[[

A "Coordinator" object represents a full "world" Coordinator>

]]

local Coordinator = objects.Class("lootplot:Coordinator")


function Coordinator:init()
    self.money = 0
    self.points = 0
end


function Coordinator:reroll()
    self.points = 0
end






return Coordinator

