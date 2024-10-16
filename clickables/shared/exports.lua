---@meta

local clickables = {}
if false then
    ---Availability: Client and Server
    _G.clickables = clickables
end

local c = require("shared.clickable")

if client then

---Get clickables input listener.
---
---Availability: **Client**
---@return input.InputListener
function clickables.getListener()
    return c.listener
end

end

umg.expose("clickables", clickables)
return clickables
