---@meta

local topdownControl = require("shared.topdown_control")

local control = {}
if false then _G.control = control end



control.getControlledEntities = require("shared.get_controlled");


if client then

function control.getListener()
    return topdownControl.listener
end

end


umg.expose("control", control)

return control
