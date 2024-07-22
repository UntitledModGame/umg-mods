local sound = {}
if false then _G.sound = sound end

---@type table<string, love.Source>
local definedSounds = {}
local definedTags = objects.Set()
---@type table<string, objects.Set>
local tagsOfSounds = {} -- [sound] = Set[tags]
---@type table<love.Source, string>
local nameBySource = setmetatable({}, {__mode = "k"})

local EFFECT_SUPPORTED = love.audio.isEffectsSupported()

---@param name string
---@param source love.Source
local function defineSound(name, source)
    if definedSounds[name] then
        definedSounds[name]:stop()
        definedSounds[name]:release()
    end

    definedSounds[name] = source

    if not tagsOfSounds then
        tagsOfSounds[name] = objects.Set()
    end
end

---@param name string
---@return boolean
local function isDefined(name)
    return not not (type(name) == "string" and definedSounds[name])
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
        umg.melt("tag '"..tag.."' is not a valid sound tag", 2)
    end
end


---@param fullpath string
local function extractFilename(fullpath)
    local rev = fullpath:reverse()
    local ext = (rev:find(".", 1, true) or 0) + 1
    local pathsep = (rev:find("/", 1, true) or (#rev + 1)) - 1

    if ext >= pathsep then
        -- Crossed path separator boundary
        ext = 1
    end

    return rev:sub(ext, pathsep):reverse()
end

local STREAM_ON_DISK_SIZE = 1 * 1000 * 1000 -- 1MB

---@param deflist objects.Set
---@param path string
---@param prefix string
---@param suffix string
---@param tags string[]
local function defineSoundRecursive(deflist, path, prefix, suffix, tags)
    local locallyLoaded = objects.Set()

    -- TODO: Replace with DirectoryObject walker
    for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
        if file:sub(1, 1) ~= "_" then
            local fullpath = path.."/"..file
            local info = love.filesystem.getInfo(fullpath)

            if info then
                if info.type == "directory" then
                    defineSoundRecursive(deflist, fullpath, prefix, suffix, tags)
                elseif info.type ~= "other" then
                    -- Try loading it
                    local stream = info.size >= STREAM_ON_DISK_SIZE and "file" or "memory"
                    local success, source = pcall(love.audio.newSource, fullpath, "stream", stream)

                    if success then
                        local name = extractFilename(file)
                        if deflist:has(name) then
                            umg.melt("duplicate sound '"..name.."' defined during iterating directory")
                        elseif locallyLoaded:has(name) then
                            umg.log.warn("sound '"..name.."' already defined with different extension and will be overridden")
                        end

                        locallyLoaded:add(name)
                        deflist:add(name)
                        defineSound(prefix..name..suffix, source)
                    end
                end
            end
        end
    end
end

typecheck.addType("sound", function(x)
    return not not isDefined(x), "expected defined sound name"
end)

typecheck.addType("soundtag", function(x)
    return isValidTag(x), "expected valid sound tag name"
end)

local defineSoundTc = typecheck.assert("string", "love:Source")

---Define a new sound.
---
---If a sound with name `name` is already defined, it will be overwriten. Use `sound.isDefined` to check.
---
---IF a sound with name `name` is redefined, the tags will not be cleared.
---@param name string Name of the sound.
---@param source love.Source Audio source template.
function sound.defineSound(name, source)
    defineSoundTc(name, source)
    return defineSound(name, source)
end

---Check if a sound with name `name` has been defined.
---@param name string Sound name to check.
---@return boolean
---@nodiscard
function sound.isDefined(name)
    return isDefined(name)
end

local defineSoundsInDirectoryTc = typecheck.assert("string", "string?", "table?", "string?")

---Define sounds in a directory, **recursively**. Any errors on loading the sound in the directory will be silently
---ignored (the sound will not be defined). By default sound less than 1MB will be loaded in-memory while sound larger
---than that will be streamed on-disk. If you need fine-grained control/exception on certain sound, re-define them
---using `sound.defineSound`.
---
---The sound will be defined with `<prefix><filename><suffix>`.
---
---**Note**: If there's multiple sound name with different extension, a warning will be issued.
---
---**Warning**: If there's multiple sound name in different directory, an error will be issued.
---@param path string Directory, of the current loading mod, to iterate.
---@param prefix string? Prefix to add to the sound name (default is empty string).
---@param tags string[]? List of tags to add when defining the sound.
---@param suffix string? Suffix to add to the sound name (default is empty string).
function sound.defineSoundsInDirectory(path, prefix, tags, suffix)
    defineSoundsInDirectoryTc(path, prefix, tags, suffix)

    -- validate tags in here so the recursive function don't have to
    tags = tags or {}
    for _, tag in ipairs(tags) do
        assertTag(tag)
    end

    if path:sub(-1) == "/" then
        -- Strip trailing slash
        path = path:sub(1, -2)
    end

    return defineSoundRecursive(objects.Set(), path, prefix or "", suffix or "", tags)
end

local validSoundTc = typecheck.assert("sound")

---Retrieve the LOVE Source object of sound `name`.
---@param name string
---@return love.Source
---@nodiscard
function sound.getSource(name)
    validSoundTc(name)

    local source = definedSounds[name]:clone()
    nameBySource[source] = name
    return source
end

local getNameTc = typecheck.assert("love:Source")

---Retrieve the sound name based on the LOVE Source object.
---@param source love.Source
---@return string
function sound.getName(source)
    getNameTc(source)

    local name = nameBySource[source]
    if not name then
        umg.melt("source is not created by the sound mod")
    end

    return name
end

local defineTagTc = typecheck.assert("string")

---Define a new tag that can be used to tag sounds.
---
---Defining existing tag is not allowed.
---@param tag string
function sound.defineTag(tag)
    defineTagTc(tag)
    if isValidTag(tag) then
        umg.melt("tag '"..tag.."' already defined")
    end

    return defineTag(tag)
end

---Add tag to the sound with name of `name`
---@param name string Valid sound name.
---@param ... string List of valid tags to assign.
function sound.tag(name, ...)
    validSoundTc(name)
    for i = 1, select("#", ...) do
        local tag = select(i, ...)
        assertTag(tag)
        tagsOfSounds[name]:add(tag)
    end
end

---Remove tag from the sound with name of `name`
---@param name string Valid sound name.
---@param ... string List of valid tags to unassign.
function sound.untag(name, ...)
    validSoundTc(name)
    for i = 1, select("#", ...) do
        local tag = select(i, ...)
        assertTag(tag)
        tagsOfSounds[name]:remove(tag)
    end
end

local hasTagTc = typecheck.assert("sound", "soundtag")

---@param name string Valid sound name.
---@param tag string Valid tag name to check.
---@return boolean
function sound.hasTag(name, tag)
    hasTagTc(name, tag)
    return tagsOfSounds[name]:has(tag)
end

---@class sound.PlayArgs
---@field public entity Entity? Entity to associate with the playing sound (passed to the bus; default to nil)
---@field public volume number? Volume of the source (default to 1.0)
---@field public pitch number? Pitch of the source (0 is not a valid value; default to 1.0)
---@field public effects table<string, boolean|table<string, any>>? Effects to apply to the source.
---@field public filter table<string, any>? Filter to apply to the source.
---@field public source love.Source? Existing source to reuse instead (must be retrieved from `sound.getSource()`)

---Play a sound with name `name` and return the underlying LOVE Source object.
---@param name string Valid sound name.
---@param args sound.PlayArgs? Play arguments.
---@return love.Source
function sound.play(name, args)
    --[[
    effects? = {[effectlist] = true|{effectparams}},
    filter? = filter
    source? = loveSource, -- Existing source to use instead (assert sound.getName(source) == "sound1")
    ]]
    validSoundTc(name)
    args = args or {}

    local source = args.source
    if source then
        sound.getName(source)
    else
        source = sound.getSource(name)
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

    umg.call("sound:transform", name, source, args.entity)

    source:play()
    return source
end

---Check if audio effects are supported.
---
---If audio effects are not supported, calls to `Source:setEffect()` and `Source:setFilter()` result in undefined
---behavior.
---@return boolean
---@nodiscard
function sound.canUseEffect()
    return EFFECT_SUPPORTED
end

umg.answer("sound:getVolume", function()
    return 1
end)

umg.answer("sound:getSemitoneOffset", function()
    return 0
end)

umg.expose("sound", sound)

return sound
