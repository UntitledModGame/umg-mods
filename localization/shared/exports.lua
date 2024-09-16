---Availability: Client and Server
---@class localization.mod
local localization = {}
if false then _G.localization = localization end

local interpolate = require("shared.interpolate")

--- Translates a string.
---@param text string String to translate
---@param variables table<string, any>? Variable to interpolate
---@param args table? Reserved for future use
---@return any
function localization.localize(text, variables, args)
    --[[
    dummy for now.
    In future, add proper translation
    ]]
    return variables and interpolate(text, variables) or text
end


umg.expose("localization", localization)
return localization
