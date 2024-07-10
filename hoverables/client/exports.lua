---@meta
local hoverables = {}
if false then _G.hoverables = hoverables end

local h = require("client.hoverables")

hoverables.isHovered = h.isHovered
hoverables.getHoveredEntities = h.getHoveredEntities

umg.expose("hoverables", h)
return h
