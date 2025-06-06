
local function define(name, path)
    local ok, source = pcall(love.audio.newSource,path, "stream", "file")
    if not ok then
        umg.melt("Couldnt load music" .. tostring(path))
    end
    audio.defineAudio(name, source, {"audio:music"})
end


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



local VOLUME_MODIFIER = 0.4
-- NOOMA ^^^ (number out of my ass)

local function setVolume(id, x)
    audio.getTemplateSource(id):setVolume(x * VOLUME_MODIFIER)
end


-- OLD MUSIC via Incompetech:
-- setVolume("lootplot.singleplayer:one_sly_move", 0.5)
-- setVolume("lootplot.singleplayer:sauve_sandpipe", 0.4)
-- setVolume("lootplot.singleplayer:zig_zag", 0.5)
-- setVolume("lootplot.singleplayer:thief", 0.65)
-- ^^^^ i got rid of these tracks coz they were kinda meh.

setVolume("lootplot.singleplayer:andreas_theme", 0.65)

setVolume("lootplot.singleplayer:whimsical_breeze", 0.6)
setVolume("lootplot.singleplayer:floppy_rules", 0.85)

setVolume("lootplot.singleplayer:fast_lanes_light_rain", 0.7)
setVolume("lootplot.singleplayer:you_were_always_in_the_right_place_no_perc", 0.75)


local musicManager = {}

musicManager.normalBGMPlaylist = music.ShufflePlaylist(unpack(normal))


function musicManager.playNormalBGM()
    return music.play(musicManager.normalBGMPlaylist)
end

return musicManager
