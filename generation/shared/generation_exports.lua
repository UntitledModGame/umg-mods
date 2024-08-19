---@meta
local generation = {}
if false then _G.generation = generation end

generation.Generator = require("shared.Generator")
---@deprecated use generation.Generator instead.
generation.LegacyGenerator = require("shared.LegacyGenerator")

umg.expose("generation", generation)

return generation
