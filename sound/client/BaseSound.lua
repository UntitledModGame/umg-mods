---@class sound.BaseSound: objects.Class
local BaseSound = objects.Class("sound:BaseSound")

---Play a sound.
---
---Note that the returned source is managed by the respective sound classes and may be pooled.
---@param ent Entity? Additional entity to associate with the sound.
---@param volume number? The volume of the audio.
---@param pitch number? The pitch multiplier of the audio (0 is not a valid value).
---@return love.Source source The played source.
function BaseSound:play(ent, volume, pitch)
    umg.melt("need to override 'play'")
end

return BaseSound
