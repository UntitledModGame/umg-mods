---@meta

---Availability: **Client**
local follow = {}

local followMod = require("client.follow")


---@param display? boolean|number Should use display or compute scale for specific zoom factor.
---@return number
function follow.getScaleFromZoom(display)
    return followMod.getScaleFromZoom(display)
end

---@param max_zoom number
function follow.setMaxZoom(max_zoom)
    return followMod.setMaxZoom(max_zoom)
end

---@param min_zoom number
function follow.setMinZoom(min_zoom)
    return followMod.setMinZoom(min_zoom)
end

---@return number
function follow.getCurrentZoomMultipler()
    return followMod.getCurrentZoomMultipler()
end

---@param zm number
function follow.setZoomMultipler(zm)
    return follow.setZoomMultipler(zm)
end

---@return number
function follow.getZoomFactor()
    return followMod.getZoomFactor()
end

---@return number,number
function follow.getZoomFactorRange()
    return followMod.getZoomFactorRange()
end

---@param speed number
function follow.setZoomSpeed(speed)
    return followMod.setZoomSpeed(speed)
end

---@param zf number
function follow.initiateZoom(zf)
    return followMod.initiateZoom(zf)
end

if false then _G.follow = follow end
umg.expose("follow", follow)
return follow
