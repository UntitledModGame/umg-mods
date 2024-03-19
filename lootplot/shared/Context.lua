
--[[

A "Context" object represents a full "world" context

]]

local Context = objects.Class("lootplot:Context")


function Context:init()
    self.money = 0
    self.points = 0
end


function Context:reset()
    self.points = 0
end






return Context

