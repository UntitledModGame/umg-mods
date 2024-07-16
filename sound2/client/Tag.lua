local Taggable = require("client.Taggable")

---@class sound.Tag: sound.Taggable
local Tag = objects.Class("sound:Tag"):implement(Taggable)

function Tag:init()
    self.effects = {}
    self.tags = objects.Set()
    self.volume = 1
    self.pitch = 1
end

---@param ... sound.Tag
function Tag:tag(...)
    for i = 1, select("#", ...) do
        self.tags:add(select(i, ...))
    end
end

---@param ... sound.Tag
function Tag:untag(...)
    for i = 1, select("#", ...) do
        self.tags:remove(select(i, ...))
    end
end

---Enable effect (with or without filters) or disable it.
---@param name string Effect name.
---@param filterSettings? boolean|table True (or nil) to enable without filters, false to remove effect, table to enable with filters.
function Tag:setEffect(name, filterSettings)
    if filterSettings == nil then filterSettings = true end
    if filterSettings == false then filterSettings = nil end
    self.effects[name] = filterSettings
end


---@param volume number
function Tag:setVolume(volume)
    self.volume = math.max(volume, 0)
    return self
end

---@param pitch number
function Tag:setPitch(pitch)
    assert(pitch > 0, "pitch must be greater than 0")
    self.pitch = pitch
    return self
end

---@return number
function Tag:getVolume()
    return self.volume
end

function Tag:getComputedVolume()
    local volume = self.volume

    for _, tag in ipairs(self.tags) do
        volume = volume * tag:getComputedVolume()
    end

    return volume
end

---@return number
function Tag:getPitch()
    return self.pitch
end

function Tag:getComputedPitch()
    local pitch = self.pitch

    for _, tag in ipairs(self.tags) do
        pitch = pitch * tag:getComputedPitch()
    end

    return pitch
end

return Tag
