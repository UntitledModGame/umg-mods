---@meta
local generation = {}
if false then _G.generation = generation end

generation.LegacyGenerator = require("shared.LegacyGenerator")

umg.expose("generation", generation)

return generation
