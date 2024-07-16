local Tag = require("client.Tag")

---@class sound.BaseSound: sound.Tag
local BaseSound = objects.Class("sound:BaseSound"):implement(Tag)

function BaseSound:init()
    return Tag.init(self)
end

---Play the sound.
---@param fadein number? Volume fade-in in seconds.
function BaseSound:play(fadein)
    umg.melt("need to override 'play'")
end

---Stop the sound.
---@param fadeout number? Volume fade-out in seconds.
function BaseSound:stop(fadeout)
    umg.melt("need to override 'stop'")
end

---Get simultaneously playing audio of this Sound.
---@return integer nplays Amount of simultaneously playing audio of this Sound.
function BaseSound:getPlayingCount()
    umg.melt("need to override 'stop'")
    return 0
end

return BaseSound
