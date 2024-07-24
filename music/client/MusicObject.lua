
local MusicInterface = {}

---@class music.MusicObject: objects.Class
local MusicObject = objects.Class("music:MusicObject")

---Retrieve the source currently "in playing".
---
---@return love.Source source The source that's currently "in playing"
function MusicObject:getCurrentSource()
    umg.melt("need to override 'getCurrentSource'")
    return nil ---@diagnostic disable-line: return-type-mismatch
end

---Update the state of the music object.
---@param dt number
function MusicObject:update(dt)
end

---Called by the music manager when an audio Source will be played.
---
---The audio source object passed is always owned by the music object itself from `MusicObject:getSource()`.
---@param source love.Source The source that's about to be played.
function MusicObject:songStartPlay(source)
end

---Called by the music manager when an audio Source playback was interrupted.
---
---Interruption can happen when the music object that's being played in the music manager was changed.
---
---The audio source object passed is always owned by the music object itself from `MusicObject:getSource()`.
---@param source love.Source The paused source that was interrupted.
function MusicObject:songInterrupted(source)
end

---Called by the music manager when an audio Source has finished playing.
---
---Note that if the source loops, this will never be called!
---
---The audio source object passed is always owned by the music object itself from `MusicObject:getSource()`.
---@param source love.Source The stopped source that was finished.
function MusicObject:songFinished(source)
end

return MusicObject
