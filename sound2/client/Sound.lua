local BaseSound = require("shared.BaseSound")

---@class sound.Sound: sound.BaseSound
local Sound = objects.Class("sound:Sound"):implement(BaseSound)

local canUseEffect = love.audio.isEffectsSupported()

---@type table<sound.Sound,boolean>
local sounds = setmetatable({}, {__mode = "k"})

---@param path string
---@param sourcetype love.SourceType
function Sound:init(path, sourcetype)
    assert(sourcetype == "stream" or sourcetype == "static", "invalid source type")
    self.source = love.audio.newSource(path, sourcetype, "file") -- original source
    self.instances = {} -- sound instances
    sounds[self] = true
end

---Play the sound.
function Sound:play(fadein)
    self.instances[#self.instances+1] = self.ripple:play({fadeDuration = fadein})
end

---Stop the sound.
function Sound:stop()
    if #self.instances > 0 then
        local inst = table.remove(self.instances, 1)
        inst:stop(fadeout)
    end
end

---Get simultaneously playing audio of this Sound.
---@return integer nplays Amount of simultaneously playing audio of this Sound.
function Sound:getPlayingCount()
    return #self.instances
end

---Enable effect (with or without filters) or disable it.
---@param effect string
---@param opts boolean|table
---@return boolean success Is effect successfully (un)applied?
function Sound:setEffect(effect, opts)
    if not canUseEffect then return false end
    return self.source:setEffect(effect, opts)
end


if false then
    ---Create new Sound.
    ---@param path string
    ---@param sourcetype love.SourceType
    ---@return sound.Sound
    function Sound(path, sourcetype) end ---@diagnostic disable-line: cast-local-type, missing-return
end

return Sound
