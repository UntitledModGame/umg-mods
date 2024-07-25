local BaseSound = require("client.BaseSound")

---@type table<sound.Sound, boolean>
local sounds = setmetatable({}, {__mode = "k"})

---@class sound.Sound: sound.BaseSound
local Sound = objects.Class("sound:Sound"):implement(BaseSound)

---@param audioName string
---@param volume number?
---@param pitch number?
function Sound:init(audioName, volume, pitch)
    if not audio.isDefined(audioName) then
        umg.melt("audio '"..audioName.."' is not defined")
    end

    self.name = audioName
    self.volume = volume or 1
    self.pitch = pitch or 1
    ---@type love.Source[]
    self.pool = {} -- unused sources
    ---@type love.Source[]
    self.playing = {} -- currently playing
    assert(self.pitch > 0, "invalid pitch value")
    sounds[self] = true
end

if false then
    ---Create new, pooled sound object.
    ---@param audioName string Valid audio name.
    ---@param volume number? Default volume multiplier (default is 1)
    ---@param pitch number? Default pitch multiplier (default is 1; 0 is not a valid value).
    ---@return sound.Sound
    ---@nodiscard
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function Sound(audioName, volume, pitch) end
end

---Play a sound.
---
---Note that the returned source is managed by the respective sound classes and may be pooled.
---@param ent Entity? Additional entity to associate with the sound.
---@param volume number? The volume of the audio.
---@param pitch number? The pitch multiplier of the audio (0 is not a valid value).
---@return love.Source source The played source.
function Sound:play(ent, volume, pitch)
    pitch = pitch or 1
    volume = volume or 1

    local source

    if #self.pool > 0 then
        source = table.remove(self.pool, 1)
    else
        source = audio.getSource(self.name)
    end

    source:stop()
    return audio.play(self.name, {
        entity = ent,
        volume = volume * self.volume,
        pitch = pitch * self.pitch,
        source = source,
    })
end


---@return number
function Sound:getPlayingCount()
    return #self.playing
end


---@package
function Sound:_update()
    for i = #self.playing, 1, -1 do
        local source = self.playing[i]
        if not source:isPlaying() and source:tell() == 0 then
            -- Reset source state
            audio.resetSource(source)

            table.remove(self.playing, i)
            self.pool[#self.pool+1] = source
        end
    end
end

umg.on("@update", function()
    for k in pairs(sounds) do
        k:_update()
    end
end)

return Sound
