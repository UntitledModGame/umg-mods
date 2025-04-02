local MusicObject = require("client.MusicObject")

---SequentialPlaylist plays all music in order they're added.
---@class music.SequentialPlaylist: music.MusicObject
local SequentialPlaylist = objects.Class("music:SequentialPlaylist"):implement(MusicObject)

---@param ... string
function SequentialPlaylist:init(...)
    self.pos = 0
    self.internalPlayingIndex = 1
    self.names = {}
    self.sources = {}
    self.currentlyPlayingRemoved = false

    for i = 1, select("#", ...) do
        self:add(select(i, ...))
    end
end

if false then
    ---Create new sequential playlist.
    ---@param ... string Valid audio names to add to the playlist.
    ---@return music.SequentialPlaylist
    ---@nodiscard
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function SequentialPlaylist(...) end
end

---Append new song to the playlist. Multiple songs with same name is allowed.
---@param audioname string Valid audio name.
function SequentialPlaylist:add(audioname)
    local source = audio.getSource(audioname)
    self.names[#self.names+1] = audioname
    self.sources[#self.sources+1] = source
end

---Remove first occurence of song from the playlist.
---@param audioname string Valid audio name.
---@return boolean success Is removal successful?
function SequentialPlaylist:remove(audioname)
    for i, v in ipairs(self.names) do
        if v == audioname then
            if self.internalPlayingIndex == i then
                self.currentlyPlayingRemoved = true
            end

            table.remove(self.names, i)
            local source = table.remove(self.sources, i)

            if self.currentlyPlayingRemoved and not source:isPlaying() then
                -- If song is interrupted state and currently playing song is removed, reset current song position
                self.pos = 0
            end

            -- math.min is to handle edge case if we're removing the last song and playingIndex is the last song too
            self.internalPlayingIndex = math.min(self.internalPlayingIndex, #self.sources)
            return true
        end
    end

    return false
end

function SequentialPlaylist:getCurrentSource()
    assert(#self.sources > 0, "no songs added in the playlist")
    return self.sources[self.internalPlayingIndex]
end

function SequentialPlaylist:getCurrentAudioName()
    assert(#self.names > 0, "no songs added in the playlist")
    return self.names[self.internalPlayingIndex]
end


---@param source love.Source
function SequentialPlaylist:songFinished(source)
    if not self.currentlyPlayingRemoved then
        -- Advance
        self.internalPlayingIndex = self.internalPlayingIndex % #self.sources + 1
    end

    self.currentlyPlayingRemoved = false
    self.pos = 0
    audio.resetSource(source)
end

---@param source love.Source
function SequentialPlaylist:songStartPlay(source)
    local name = audio.getName(source)
    source:setVolume(audio.getVolume(name, source))
    source:setPitch(audio.getPitch(name, source))
    audio.transform(name, source)
    source:seek(self.pos)
end

---@param source love.Source
function SequentialPlaylist:songInterrupted(source)
    if self.currentlyPlayingRemoved then
        self.pos = 0
    else
        self.pos = source:tell()
    end

    audio.resetSource(source)
end

return SequentialPlaylist
