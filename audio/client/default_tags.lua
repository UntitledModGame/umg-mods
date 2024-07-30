

local audio = require("client.audio")


--[[

All default tags:

TODO: should music be a tag? or not???

]]
audio.defineTag("audio:sfx")
audio.defineTag("audio:music")


umg.answer("audio:getVolume", function(name)
    if audio.hasTag(name, "audio:music") then
        return client.getMusicVolume()
    elseif audio.hasTag(name, "audio:sfx") then
        return client.getSFXVolume()
    end

    return 1
end)

