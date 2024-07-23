local BaseSound = require("client.BaseSound")

---@class sound.VarianceSound: objects.Class
local VarianceSound = objects.Class("sound:VarianceSound"):implement(BaseSound)

---@param variance number
---@param init number?
---@return {[1]:number,[2]:number}
local function makeToRange(variance, init)
    init = init or 0
    return {init - variance, init + variance}
end

---@param range {[1]:number,[2]:number}
local function randomizeByRange(range)
    local t = math.random()
    return (1 - t) * range[1] + t * range[2]
end

---@param sound sound.BaseSound
---@param volumeVariance? number|{[1]:number,[2]:number}
---@param semitoneVariance? number|{[1]:number,[2]:number}
function VarianceSound:init(sound, volumeVariance, semitoneVariance)
    if type(volumeVariance) == "number" then
        volumeVariance = makeToRange(volumeVariance, 1)
    end

    if type(semitoneVariance) == "number" then
        semitoneVariance = makeToRange(semitoneVariance)
    end

    assert(volumeVariance or semitoneVariance, "one of volume variance or semitone variance must be specified")

    self.sound = sound
    self.volumeVariance = volumeVariance
    self.semitoneVariance = semitoneVariance
end

if false then
    ---Create new sound object based on existing sound object that randomizes the volume and/or pitch everytime the
    ---sound is being played.
    ---@param sound sound.BaseSound Existing sound object.
    ---@param volumeVariance? number|{[1]:number,[2]:number} The volume variance (number means 1 +- variance) or a range of values.
    ---@param semitoneVariance? number|{[1]:number,[2]:number} The semitone variance or a range of values.
    ---@return sound.VarianceSound
    ---@nodiscard
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function VarianceSound(sound, volumeVariance, semitoneVariance) end
end

---Play a sound.
---
---Note that the returned source is managed by the respective sound classes and may be pooled.
---@param ent Entity? Additional entity to associate with the sound.
---@param volume number? The volume of the audio.
---@param pitch number? The pitch multiplier of the audio (0 is not a valid value).
---@return love.Source source The played source.
function VarianceSound:play(ent, volume, pitch)
    volume = volume or 1
    pitch = pitch or 1

    if self.volumeVariance then
        volume = volume * randomizeByRange(self.volumeVariance)
    end

    if self.semitoneVariance then
        pitch = pitch * 2 ^ (randomizeByRange(self.semitoneVariance) / 12)
    end

    return self.sound:play(ent, volume, pitch)
end

return VarianceSound
