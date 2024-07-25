
---@class lootplot.sound.LootplotSound: sound.BaseSound
local LootplotSound = objects.Class("lootplot.sound:LootplotSound")
    :implement(sound.BaseSound)



function LootplotSound:init(soundName, volume, pitch, maxSounds, pitchVar)
    self.sound = sound.Sound(soundName, volume, pitch)
    self.maxSounds = maxSounds or 20
    self.pitchVar = pitchVar or 0.1
end


function LootplotSound:play(ent)
    if self.sound:getPlayingCount() > self.maxSounds then
        return -- dont play any more!
    end
    local dPitch = self.pitchVar * (math.random() - 0.5) * 2
    return self.sound:play(ent, 1, 1+dPitch)
end


---@cast LootplotSound +fun(soundName:string, volume?:number, pitch?:number, maxSounds?:number, pitchVar?:number): lootplot.sound.LootplotSound
return LootplotSound

