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
---@param source love.Source
local function defineSound(name, source)
    if definedAudios[name] then
        definedAudios[name]:stop()
        definedAudios[name]:release()
    end

    definedAudios[name] = source

    if not tagsOfAudios then
        tagsOfAudios[name] = objects.Set()
    end
end

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

local defineSoundTc = typecheck.assert("string", "love:Source")

---Define a new sound.
---
---If an audio with name `name` is already defined, it will be overwriten. Use `sound.isDefined` to check.
---
---IF an audio with name `name` is redefined, the tags will not be cleared.
---@param name string Name of the sound.
---@param source love.Source Audio source template.
function audio.defineAudio(name, source)
    defineSoundTc(name, source)
    return defineSound(name, source)
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
---@param dirobj umg.DirectoryObject Directory, of the current loading mod, to iterate.
---@param prefix string? Prefix to add to the audio name (default is empty string).
---@param tags string[]? List of tags to add when defining the sound.
---@param suffix string? Suffix to add to the audio name (default is empty string).
function audio.defineAudiosInDirectory(dirobj, prefix, tags, suffix)
    defineSoundsInDirectoryTc(dirobj, prefix, tags, suffix)

    prefix = prefix or ""
    suffix = suffix or ""
    -- validate tags
    tags = tags or {}
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
                        defineSound(prefix..filename..suffix, source)
                    else
                        umg.log.error("attempt to load as source", fullpath, source)
                    end
                end
            end
        end
    end)
end

local validSoundTc = typecheck.assert("sound")

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

---Add tag to the sound with name of `name`
---@param name string Valid audio name.
---@param ... string List of valid tags to assign.
function audio.tag(name, ...)
    validSoundTc(name)
    for i = 1, select("#", ...) do
        local tag = select(i, ...)
        assertTag(tag)
        tagsOfAudios[name]:add(tag)
    end
end

---Remove tags from the audio with name of `name`
---@param name string Valid audio name.
---@param ... string List of valid tags to unassign.
function audio.untag(name, ...)
    validSoundTc(name)
    for i = 1, select("#", ...) do
        local tag = select(i, ...)
        assertTag(tag)
        tagsOfAudios[name]:remove(tag)
    end
end

local hasTagTc = typecheck.assert("sound", "soundtag")

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
        audio.getName(source)
    else
        source = audio.getSource(name)
    end

    local volume = (args.volume or 1) * umg.ask("sound:getVolume", name, source, args.entity)
    local semitone = umg.ask("sound:getSemitoneOffset", name, source, args.entity)
    local pitch = (args.pitch or 1) * 2 ^ (semitone / 12)

    source:setVolume(volume)
    source:setPitch(pitch)

    if EFFECT_SUPPORTED and args.effects then
        for k, v in pairs(args.effects) do
            source:setEffect(k, v)
        end
    end

    if EFFECT_SUPPORTED and args.filter then
        source:setFilter(args.filter)
    end

    umg.call("audio:transform", name, source, args.entity)

    source:play()
    return source
end

---Check if audio effects are supported.
---
---If audio effects are not supported, calls to `Source:setEffect()` and `Source:setFilter()` result in undefined
---behavior.
---@return boolean
---@nodiscard
function audio.canUseEffect()
    return EFFECT_SUPPORTED
end

umg.answer("audio:getVolume", function()
    return 1
end)

umg.answer("audio:getSemitoneOffset", function()
    return 0
end)

umg.expose("audio", audio)

return audio
