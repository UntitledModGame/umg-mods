---@param name string
---@param path string
---@param volume number?
local function define(name, path, volume)
    local source = love.audio.newSource(path, "stream", "file")
    source:setVolume(volume or 1)
    audio.defineAudio(name, source)
    audio.tag(name, "audio:music")
end

define("lootplot.main:bgm1", "assets/music/Galactic Rap.mp3", 0.7)
define("lootplot.main:bgm2", "assets/music/密約.mp3", 0.7)
define("lootplot.main:bgm3", "assets/music/Old_Fashion.mp3", 0.7)
define("lootplot.main:bgm4", "assets/music/One Sly Move.mp3", 0.7)
define("lootplot.main:bgm5", "assets/music/Suave Standpipe.mp3", 0.7)
define("lootplot.main:boss_bgm1", "assets/music/Dream Catcher.mp3", 0.7)
define("lootplot.main:boss_bgm2", "assets/music/BGM_-_027_-_Mist_In_The_Dark.mp3", 0.7)
define("lootplot.main:boss_bgm3", "assets/music/破滅を呼びしモノ.mp3", 0.7)

local musicManager = {}

musicManager.normalBGMPlaylist = music.ShufflePlaylist(
    "lootplot.main:bgm1",
    "lootplot.main:bgm2",
    "lootplot.main:bgm3",
    "lootplot.main:bgm4",
    "lootplot.main:bgm5"
)

musicManager.bossBGMPlaylist = music.ShufflePlaylist(
    "lootplot.main:boss_bgm1",
    "lootplot.main:boss_bgm2",
    "lootplot.main:boss_bgm3"
)

function musicManager.playNormalBGM()
    return music.play(musicManager.normalBGMPlaylist)
end

function musicManager.playBossBGM()
    return music.play(musicManager.bossBGMPlaylist)
end

return musicManager
