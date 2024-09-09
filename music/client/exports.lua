local music = {}
if false then _G.music = music end

---@alias music.MusicInterface {getCurrentSource:(fun(self:any):love.Source),update?:fun(self:any,dt:number),songStartPlay?:fun(self:any,source:love.Source),songInterrupted?:fun(self:any,source:love.Source),songFinished?:fun(self:any,source:love.Source)}

---@type music.MusicInterface?
local currentMusicObject = nil
---@type love.Source?
local currentSource = nil

---@param obj music.MusicInterface?
function music.play(obj)
    if currentMusicObject then
        if currentSource then
            currentSource:pause()
            currentMusicObject:songInterrupted(currentSource)
            currentSource = nil
        end
        currentMusicObject = nil
    end

    currentMusicObject = obj

    if currentMusicObject then
        currentSource = currentMusicObject:getCurrentSource()
        currentMusicObject:songStartPlay(currentSource)
        currentSource:play()
    end
end

---@type music.SequentialPlaylist
local foo = nil

music.play(foo)

umg.on("@update", function(dt)
    if currentMusicObject then
        if not currentSource then
            currentSource = currentMusicObject:getCurrentSource()
            currentMusicObject:songStartPlay(currentSource)
            currentSource:play()
        end

        currentMusicObject:update(dt)

        if not currentSource:isPlaying() and currentSource:tell() == 0 then
            currentMusicObject:songFinished(currentSource)
            currentSource = currentMusicObject:getCurrentSource()
            currentMusicObject:songStartPlay(currentSource)
            currentSource:play()
        end
    end
end)

umg.on("@quit", function()
    if currentSource then
        currentSource:stop()
        currentSource = nil
    end

    currentMusicObject = nil
end)

music.SequentialPlaylist = require("client.SequentialPlaylist")
music.ShufflePlaylist = require("client.ShufflePlaylist")

umg.expose("music", music)
return music
