---Availability: Client and Server
---@class control
local control = {}
if false then
    _G.control = control
end


local topdownControl = require("shared.topdown_control")
local getControlledEntities = require("shared.get_controlled")

---Availability: Client and Server
---@param clientId string? (required if called from **server**)
---@return objects.Set
function control.getControlledEntities(clientId)
    return getControlledEntities(clientId)
end


if client then

---Get control input listener.
---
---Availability: **Client**
---@return input.InputListener
function control.getListener()
    return topdownControl.listener
end

end


umg.expose("control", control)
return control
