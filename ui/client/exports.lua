---Provides user interface functionality.
---
---Availability: **Client**
---@class ui
local ui = {}

ui.elements = require("client.elements")
ui.Element = require("client.newElement")

local helper = require("client.helper")



local drawImageTc = typecheck.assert("love:Texture|love:Quad|string", "number",  "number",  "number",  "number")
---@param image string|love.Quad|love.Texture
---@param x number
---@param y number
---@param w number
---@param h number
---@param rot? number
function ui.drawImageInBox(image,x,y,w,h,rot)
    drawImageTc(image,x,y,w,h)
    return helper.drawImageInBox(image,x,y,w,h,rot)
end



if false then
    _G.ui = ui
end
umg.expose("ui", ui)
return ui
