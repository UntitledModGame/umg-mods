local BaseSound = require("client.BaseSound")

---Internal class used by Sound
---@class sound.Instance: sound.BaseSound
local Instance = objects.Class("sound:Instance"):implement(BaseSound)

local canUseEffect = love.audio.isEffectsSupported()

---@param parent sound.Sound
function Instance:init(parent)
    BaseSound.init(self)
    self.parent = parent
    self.source = parent.source:clone()
end

---@param effect string
---@param opts boolean|table
function Instance:setEffect(effect, opts)
    if canUseEffect then
        return self.source:setEffect(effect, opts)
    end
end

function Instance:setVolume(volume)
    self.volume = volume
    self.source:setVolume(self:getComputedVolume())
end

function Instance:setPitch(pitch)
    self.pitch = pitch
    self.source:setPitch(self:getComputedPitch())
end

return Instance
