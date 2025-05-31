---Availability: **Client**
---@class audio
local audio = {}
if false then _G.audio = audio end

---@type table<string, love.Source>
local definedAudios = {}
local definedTags = objects.Set()
---@type table<string, objects.Set>
local tagsOfAudios = {} -- [audio] = Set[tags]
---@type table<love.Source, string>
local nameBySource = setmetatable({}, {__mode = "k"})

local EFFECT_SUPPORTED = love.audio.isEffectsSupported()


---@param name string
---@return boolean
local function isDefined(name)
    return not not (type(name) == "string" and definedAudios[name])
end

---@param tag string
local function defineTag(tag)
    definedTags:add(tag)
end

local function isValidTag(tag)
    return type(tag) == "string" and definedTags:has(tag)
end

local function assertTag(tag)
    if not isValidTag(tag) then
        umg.melt("tag '"..tag.."' is not a valid audio tag", 2)
    end
end

typecheck.addType("audio", function(x)
    return not not isDefined(x), "expected defined audio name"
end)

typecheck.addType("audiotag", function(x)
    return isValidTag(x), "expected valid audio tag name"
end)

local defineAudioTc = typecheck.assert("string", "love:Source")

---Define a new sound.
---
---If an audio with name `name` is already defined, it will be overwriten. Use `sound.isDefined` to check.
---
---IF an audio with name `name` is redefined, the tags will not be cleared.
---@param name string Name of the sound.
---@param source love.Source Audio source template.
---@param tags string[] List of tags for this audio
function audio.defineAudio(name, source, tags)
    defineAudioTc(name, source)
    if definedAudios[name] then
        definedAudios[name]:stop()
        definedAudios[name]:release()
    end

    definedAudios[name] = source
    tagsOfAudios[name] = objects.Set(tags)
end

---Check if an audio with name `name` has been defined.
---@param name string audio name to check.
---@return boolean
---@nodiscard
function audio.isDefined(name)
    return isDefined(name)
end

local defineSoundsInDirectoryTc = typecheck.assert("table", "string?", "table?", "string?")

---Define audios in a directory, **recursively**. Any errors on loading the audio in the directory will be silently
---ignored (the audio will not be defined). If you need fine-grained control/exception on certain sound, re-define
---them using `audio.defineAudio`.
---
---The sound will be defined with `<prefix><filename><suffix>`.
---
---**Warning**: If there's multiple audio name in with different extension or in a different directory, an error will
---be issued.
---@param dirobj umg.FilesystemObject Directory, of the current loading mod, to iterate.
---@param tags string[] List of tags to add when defining the sound.
---@param prefix string? Prefix to add to the audio name (default is empty string).
---@param suffix string? Suffix to add to the audio name (default is empty string).
function audio.defineAudioInDirectory(dirobj, tags, prefix, suffix)
    defineSoundsInDirectoryTc(dirobj, prefix, tags, suffix)

    prefix = prefix or ""
    suffix = suffix or ""
    -- validate tags
    for _, tag in ipairs(tags) do
        assertTag(tag)
    end

    local deflist = objects.Set()

    return dirobj:foreachFile("", function (path, filename, extension)
        if filename:sub(1, 1) ~= "_" then
            local fullpath = path.."/"..filename..(extension or "")
            local info = dirobj:getInfo(fullpath)

            if info and info.type ~= "directory" then
                local filedata = dirobj:newFileData(fullpath)

                if filedata then
                    -- Try loading it
                    local success, source = pcall(love.audio.newSource, filedata, "stream", "memory")
                    filedata:release()

                    if success then
                        if deflist:has(filename) then
                            source:release()
                            umg.melt("duplicate sound '"..filename.."' defined during iterating directory")
                        end

                        deflist:add(filename)
                        audio.defineAudio(prefix..filename..suffix, source, tags)
                    else
                        umg.log.error("attempt to load as source", fullpath, source)
                    end
                end
            end
        end
    end)
end

local validSoundTc = typecheck.assert("audio")

---Retrieve the LOVE Source object of audio `name`.
---@param name string Valid audio name.
---@return love.Source
---@nodiscard
function audio.getSource(name)
    validSoundTc(name)

    local source = definedAudios[name]:clone()
    nameBySource[source] = name
    return source
end


---Retrieve the Template LOVE Source object of audio `name`.
--- WARNING: Mutating this source will affect ALL other occurances of this audio!
---@param name any
---@return love.Source
function audio.getTemplateSource(name)
    validSoundTc(name)
    return definedAudios[name]
end



local getNameTc = typecheck.assert("love:Source")

---Retrieve the audio name based on the LOVE Source object.
---@param source love.Source
---@return string
---@nodiscard
function audio.getName(source)
    getNameTc(source)

    local name = nameBySource[source]
    if not name then
        umg.melt("source is not created by the sound mod")
    end

    return name
end

local defineTagTc = typecheck.assert("string")

---Define a new tag that can be used to tag audios.
---
---Defining existing tag is not allowed.
---@param tag string
function audio.defineTag(tag)
    defineTagTc(tag)
    if isValidTag(tag) then
        umg.melt("tag '"..tag.."' already defined")
    end

    return defineTag(tag)
end

--- Add tag to the sound with name of `name`.
--- (Useful for adding extra tags to audios defined by other mods)
---@param name string Valid audio name.
---@param tags string[] List of valid tags to assign.
function audio.tag(name, tags)
    validSoundTc(name)
    for _,t in ipairs(tags) do
        assertTag(t)
        tagsOfAudios[name]:add(t)
    end
end


local hasTagTc = typecheck.assert("audio", "audiotag")

---Check if an audio is tagged with specific tag.
---@param name string Valid audio name.
---@param tag string Valid tag name to check.
---@return boolean
function audio.hasTag(name, tag)
    hasTagTc(name, tag)
    return tagsOfAudios[name]:has(tag)
end

---@class sound.PlayArgs
---@field public entity Entity? Entity to associate with the playing sound (passed to the bus; default to nil)
---@field public volume number? Volume of the source (default to 1.0)
---@field public pitch number? Pitch of the source (0 is not a valid value; default to 1.0)
---@field public effects table<string, boolean|table<string, any>>? Effects to apply to the source.
---@field public filter table<string, any>? Filter to apply to the source.
---@field public source love.Source? Existing source to reuse instead (must be retrieved from `audio.getSource()`)

---Play an audio with name `name` and return the underlying LOVE Source object.
---@param name string Valid audio name.
---@param args sound.PlayArgs? Play arguments.
---@return love.Source
function audio.play(name, args)
    --[[
    effects? = {[effectlist] = true|{effectparams}},
    filter? = filter
    source? = loveSource, -- Existing source to use instead (assert sound.getName(source) == "sound1")
    ]]
    validSoundTc(name)
    args = args or {}

    local source = args.source
    if source then
        assert(audio.getName(source) == name, "invalid existing source passed")
    else
        source = audio.getSource(name)
    end

    local template = definedAudios[name]
    local volume = (args.volume or 1) * template:getVolume() * audio.getVolume(name, source, args.entity)
    local pitch = (args.pitch or 1) * template:getPitch() * audio.getPitch(name, source, args.entity)
    if pitch == 0 then
        -- this can happen if there are so valid audio devices
        pitch = 1
    end

    source:setVolume(volume)
    source:setPitch(pitch)

    if love.audio.isEffectsSupported() and args.effects then
        for k, v in pairs(args.effects) do
            source:setEffect(k, v)
        end
    end

    if love.audio.isEffectsSupported() and args.filter then
        source:setFilter(args.filter)
    end

    audio.transform(name, source, args.entity)

    source:play()
    return source
end



--- Updates the pitch/volume of a source.
--- Should be called when music is playing, or else the SFX wont update.
--- (Should also be called on any long sound Fx)
---@param name any
---@param source any
---@param ent? Entity
function audio.updateSource(name, source, ent)
    local template = definedAudios[name]
    local volume = template:getVolume() * audio.getVolume(name, source, ent)
    local pitch = template:getPitch() * audio.getPitch(name, source, ent)

    source:setVolume(volume)
    source:setPitch(pitch)
end


---Retrieve the volume of the audio using question bus.
---@param name string Valid audio name.
---@param source love.Source Source associated with the audio with name of `name`.
---@param entity Entity? Entity to pass to the event bus.
---@return number volume The volume of the audio.
---@nodiscard
function audio.getVolume(name, source, entity)
    assert(audio.getName(source) == name, "invalid source passed")
    return umg.ask("audio:getVolume", name, source, entity)
end

---Retrieve the semitone offset of the audio using question bus.
---@param name string Valid audio name.
---@param source love.Source Source associated with the audio with name of `name`.
---@param entity Entity? Entity to pass to the event bus.
---@return number volume The volume of the audio.
---@nodiscard
function audio.getSemitoneOffset(name, source, entity)
    assert(audio.getName(source) == name, "invalid source passed")
    return umg.ask("audio:getSemitoneOffset", name, source, entity)
end

---Shorthand of `2 ^ (audio.getSemitoneOffset(...) / 12)`.
---@param name string Valid audio name.
---@param source love.Source Source associated with the audio with name of `name`.
---@param entity Entity? Entity to pass to the event bus.
---@return number volume The volume of the audio.
---@nodiscard
function audio.getPitch(name, source, entity)
    return 2 ^ (audio.getSemitoneOffset(name, source, entity) / 12)
end

---Apply transformation to the audio, such as applying effects, by calling the event buses.
---@param name string Valid audio name.
---@param source love.Source Source associated with the audio with name of `name`.
---@param entity Entity? Entity to pass to the event bus.
function audio.transform(name, source, entity)
    assert(audio.getName(source) == name, "invalid source passed")
    umg.call("audio:transform", name, source, entity)
end

---A helper function to reset whole state of an audio Source.
---@param source love.Source Source to reset its state.
function audio.resetSource(source)
    source:stop()
    source:seek(0)
    source:setVolumeLimits(0, 1)
    source:setPitch(1)
    source:setVolume(1)
    source:setLooping(false)

    if source:getChannelCount() == 1 then
        source:setAirAbsorption(0)
        source:setAttenuationDistances(1, 3.402823466e+38) -- float max value
        source:setCone(math.pi * 2, math.pi * 2, 0)
        source:setDirection(0, 0, 0)
        source:setPosition(0, 0, 0)
        source:setRelative(false)
        source:setRolloff(1)
        source:setVelocity(0, 0, 0)
    end

    if love.audio.isEffectsSupported() then
        for _, e in ipairs(source:getActiveEffects()) do
            source:setEffect(e, false)
        end

        source:setFilter()
    end
end

umg.expose("audio", audio)

return audio
