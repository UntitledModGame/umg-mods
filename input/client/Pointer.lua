

local Pointer = objects.Class("input:Pointer")


function Pointer:init()
    self.x = 0
    self.y = 0
end



function Pointer:mousemoved(x,y,dx,dy)
    self.x = x
    self.y = y
end



return Pointer

