
local function define(name, path)
    local ok, source = pcall(love.audio.newSource,path, "stream", "file")
    if not ok then
        umg.melt("Couldnt load music" .. tostring(path))
    end
    audio.defineAudio(name, source)
    audio.tag(name, "audio:music")
end


local epic = objects.Array()
local normal = objects.Array()


local dirObj = umg.getModFilesystem()

local function load(arr, path, filename, extension)
    if filename:sub(1, 1) == "_" then
        return -- ignore
    end
    local fullpath = path.."/"..filename..(extension or "")
    local id = "lootplot.singleplayer:" .. filename
    define(id, fullpath)
    arr:add(id)
end


dirObj:foreachFile("assets/music/normal", function(path, filename, extension)
    load(normal, path, filename, extension)
end)

dirObj:foreachFile("assets/music/epic", function(path, filename, extension)
    load(epic, path, filename, extension)
end)


local function setVolume(id, x)
    audio.getSource(id):setVolume(0.7)
end
--[[
If we want to change volume of any music, do it here:

setVolume("lootplot.singleplayer:zigzag.mp3", 0.7)

]]


local musicManager = {}

musicManager.normalBGMPlaylist = music.ShufflePlaylist(unpack(normal))

musicManager.bossBGMPlaylist = music.ShufflePlaylist(unpack(epic))


function musicManager.playNormalBGM()
    return music.play(musicManager.normalBGMPlaylist)
end

function musicManager.playBossBGM()
    return music.play(musicManager.bossBGMPlaylist)
end

return musicManager
