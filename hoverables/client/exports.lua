
---Availability: **Client**
---@class hoverables
local hoverables = {}
if false then
    _G.hoverables = hoverables
end

local h = require("client.hoverables")

hoverables.isHovered = h.isHovered
hoverables.getHoveredEntities = h.getHoveredEntities

---@return input.InputListener
function hoverables.getListener()
    return h.listener
end

umg.expose("hoverables", hoverables)
return hoverables
