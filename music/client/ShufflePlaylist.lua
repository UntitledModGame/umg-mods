local MusicObject = require("client.MusicObject")

---ShufflePlaylist plays all music in random order but guarantee all songs are played once.
---@class music.ShufflePlaylist: music.MusicObject
local ShufflePlaylist = objects.Class("music:ShufflePlaylist"):implement(MusicObject)

---@param ... string
function ShufflePlaylist:init(...)
    self.pos = 0
    self.internalPlayingIndex = 1
    self.names = {}
    self.sources = {}
    self.currentlyPlayingRemoved = true
    self.dirty = false

    for i = 1, select("#", ...) do
        self:add(select(i, ...))
    end
end

if false then
    ---Create new shufle playlist.
    ---@param ... string Valid audio names to add to the playlist.
    ---@return music.SequentialPlaylist
    ---@nodiscard
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function ShufflePlaylist(...) end
end

---Append new song to the playlist. Multiple songs with same name is allowed.
---@param audioname string Valid audio name.
function ShufflePlaylist:add(audioname)
    local source = audio.getSource(audioname)
    self.names[#self.names+1] = audioname
    self.sources[#self.sources+1] = source
    self.dirty = true
end

---@private
function ShufflePlaylist:_reshuffle()
    if self.dirty then
        for i = #self.sources, 2, -1 do
            local j = math.random(i)
            self.sources[i], self.sources[j] = self.sources[j], self.sources[i]
            self.names[i], self.names[j] = self.names[j], self.names[i]
        end
    end
end

---Remove first occurence of song from the playlist.
---@param audioname string Valid audio name.
---@return boolean success Is removal successful?
function ShufflePlaylist:remove(audioname)
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
            self.dirty = true
            return true
        end
    end

    return false
end

function ShufflePlaylist:getCurrentSource()
    assert(#self.sources > 0, "no songs added in the playlist")
    self:_reshuffle()
    return self.sources[self.internalPlayingIndex]
end

---@param source love.Source
function ShufflePlaylist:songFinished(source)
    if not self.currentlyPlayingRemoved then
        -- Advance
        self.internalPlayingIndex = (self.internalPlayingIndex - 1) % #self.sources + 1
        self.dirty = #self.sources > 1 and self.internalPlayingIndex == 1
    end

    self.pos = 0
    audio.resetSource(source)
end

---@param source love.Source
function ShufflePlaylist:songStartPlay(source)
    local name = audio.getName(source)
    source:setVolume(audio.getVolume(name, source))
    source:setPitch(audio.getPitch(name, source))
    audio.transform(name, source)
    source:seek(self.pos)
end

---@param source love.Source
function ShufflePlaylist:songInterrupted(source)
    if self.currentlyPlayingRemoved then
        self.pos = 0
    else
        self.pos = source:tell()
    end

    audio.resetSource(source)
end

return ShufflePlaylist
