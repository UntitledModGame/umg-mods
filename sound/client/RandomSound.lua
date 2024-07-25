local BaseSound = require("client.BaseSound")

---@class sound.RandomSound: sound.BaseSound
local RandomSound = objects.Class("sound:RandomSound"):implement(BaseSound)

---@param ... sound.Sound
function RandomSound:init(...)
    assert(select("#", ...) > 1, "at least 2 or more Sound must be specified")
    self.sounds = {...}
end

if false then
    ---@param ... sound.BaseSound Existing sound objects (2 or more)
    ---@return sound.RandomSound
    ---@nodiscard
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function RandomSound(...) end
end

---Play a sound.
---
---Note that the returned source is managed by the respective sound classes and may be pooled.
---@param ent Entity? Additional entity to associate with the sound.
---@param volume number? The volume of the audio.
---@param pitch number? The pitch multiplier of the audio (0 is not a valid value).
---@return love.Source source The played source.
function RandomSound:play(ent, volume, pitch)
    return table.random(self.sounds):play(ent, volume, pitch)
end

return RandomSound
