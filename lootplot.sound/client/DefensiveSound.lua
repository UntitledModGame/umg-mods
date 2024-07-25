
---@class lootplot.sound.DefensiveSound
local DefensiveSound = objects.Class("lootplot.sound:DefensiveSound")
    :implement(sound.BaseSound)



function DefensiveSound:init(soundName, volume, pitch, maxSounds)
    self.sound = sound.Sound(soundName, volume, pitch)
    self.maxSounds = maxSounds or 20
end


function DefensiveSound:play(ent)
    if self.sound:getPlayingCount() > self.maxSounds then
        return -- dont play any more!
    end
    return self.sound:play(ent)
end


return DefensiveSound

