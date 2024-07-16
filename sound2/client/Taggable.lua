---@class sound.Taggable: objects.Class
local Taggable = objects.Class("sound:Taggable")

---@param ... sound.Tag
---@return sound.Taggable
function Taggable:tag(...)
    umg.melt("abstract method 'tag'")
    return self
end

---@param ... sound.Tag
---@return sound.Taggable
function Taggable:untag(...)
    umg.melt("abstract method 'untag'")
    return self
end

---Enable effect (with or without filters) or disable it.
---@param name string Effect name.
---@param filterSettings boolean|table True to enable without filters, false to remove effect, table to enable with filters.
---@return sound.Taggable
function Taggable:setEffect(name, filterSettings)
    umg.melt("abstract method 'setEffect'")
    return self
end

---@param volume number
function Taggable:setVolume(volume)
    umg.melt("abstract method 'setVolume'")
    return self
end

---@param pitch number
function Taggable:setPitch(pitch)
    umg.melt("abstract method 'setPitch'")
    return self
end

---@return number
function Taggable:getVolume()
    umg.melt("abstract method 'getVolume'")
    return 0
end

---@return number
function Taggable:getPitch()
    umg.melt("abstract method 'getPitch'")
    return 0
end

return Taggable
