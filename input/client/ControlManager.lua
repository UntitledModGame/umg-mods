

local ControlManager = objects.Class("input:ControlManager")



local function toAxis(axis)

end


function ControlManager:init()
    self.controlToInputs = {--[[
        [controlEnum] -> {
            "key:a", "mouse:1", ...
        }
    ]]}

    self.inputToControls = {--[[
        [input] -> 
    ]]}
end





return ControlManager

