---Availability: Client and Server
---@class localization
local localization = {}
if false then
    _G.localization = localization
end

local interpolate = require("shared.interpolate")

---@type table<string, table<string, string>>
local stringsToLocalize = {}
---@type table<string, localization.Interpolator>
local interpolators = {}
local EXPORT_ON_EXIT = true


---@type table<string, table<string, string>>
local translatedKeys = {--[[
    [modname] -> {
        [string] -> translatedString
    }
]]}


---@class localization.InterpolatorObject: objects.Class
local Interpolator = objects.Class("localization:Interpolator")

---@param modname string
---@param text string
function Interpolator:init(modname, text, context)
    self.modname = modname

    if translatedKeys[modname] and translatedKeys[modname][text] then
        self.text = translatedKeys[modname][text]
    else
        self.text = text
    end

    --[[
    dummy for now.
    In future, add proper translation
    ]]
    if not stringsToLocalize[modname] then
        stringsToLocalize[modname] = {}
    end

    stringsToLocalize[modname][text] = text
end

---Availability: Client and Server
---@param variables table<string, any>? Variable to interpolate
function Interpolator:__call(variables)
    return variables and interpolate(self.text, variables) or self.text
end

---Availability: Client and Server
function Interpolator:__tostring()
    return string.format("localization:Interpolator %p: %s", self, self.text)
end


local strTc = typecheck.assert("string")

---@alias localization.Interpolator localization.InterpolatorObject|fun(variables:table<string,any>?):string

---Create new interpolator that translates and interpolates based on variables, taking pluralization into account.
---
---Availability: Client and Server
---@param text string String to translate
---@param context table? Reserved for future use
---@return localization.Interpolator
function localization.newInterpolator(text, context)
    strTc(text)
    local lctx = assert(umg.getLoadingContext(), "this can only be called at load-time")
    local key = lctx.modname.."\0"..text
    local interpolator = interpolators[key]

    if not interpolator then
        interpolator = Interpolator(lctx.modname, text)
        interpolators[key] = interpolator
    end

    return interpolator
end


---Translates a string.
---
---Availability: Client and Server
---@param text string String to translate
---@param variables table<string, any>? Variable to interpolate
---@param context table? Reserved for future use
---@return string
function localization.localize(text, variables, context)
    return localization.newInterpolator(text, context)(variables)
end


local function loadTranslations(modname, locs)
    if not translatedKeys[modname] then
        translatedKeys[modname] = {}
    end

    -- TODO: Handle pluralization
    for k, v in pairs(locs) do
        translatedKeys[modname][k] = v
    end
end


---@param fsysobj umg.FilesystemObject
---@param path string
---@return table?
local function readJson(fsysobj, path)
    if fsysobj:exists(path) then
        local locData, err = fsysobj:read(path)
        if locData then
            local status, locs = pcall(json.decode, locData)
            if status then
                return locs
            else
                umg.log.error("unable to load localization: "..locs)
            end
        else
            umg.log.error("unable to load localization: "..err)
        end
    end
end


---Load localization DIRECTLY.
---This supports data from multiple mods.
--- { [mod] -> { str -> str }}
---
---Note: currently does nothing server-side.
---
---Availability: Client and Server
---@param fsysobj umg.FilesystemObject
function localization.loadGlobal(fsysobj)
    if not client then
        return
    end

    local lang = client.getLanguage()
    local countryCodeOnly = lang:match("(%l%l)-%u%u")
    if countryCodeOnly then
        local globalTabl = readJson(fsysobj, countryCodeOnly..".json") or {}
        for modname, tabl in pairs(globalTabl) do
            loadTranslations(modname, tabl)
        end
    end

    local globalTabl = readJson(fsysobj, lang..".json") or {}
    for modname, tabl in pairs(globalTabl) do
        loadTranslations(modname, tabl)
    end
end



---Load localization data from filesystem object (callable only during initialization).
---
---Note: This currently does nothing server-side.
---
---Availability: Client and Server
---@param fsysobj umg.FilesystemObject
function localization.loadMod(fsysobj)
    if not client then
        return
    end
    local lctx = assert(umg.getLoadingContext(), "this can only be called at load-time")
    local lang = client.getLanguage()

    -- Localization file without country-specific code has lower priority.
    local countryCodeOnly = lang:match("(%l%l)-%u%u")
    if countryCodeOnly then
        local tabl = readJson(fsysobj, "localization/"..countryCodeOnly..".json")
        if tabl then loadTranslations(lctx.modname, tabl) end
    end

    local tabl = readJson(fsysobj, "localization/"..lang..".json")
    if tabl then loadTranslations(lctx.modname, tabl) end
end




if EXPORT_ON_EXIT then

umg.on("@quit", function()
    local fsobj = (server or client).getSaveFilesystem()
    local jsondata = fsobj:read("localization.json")
    local strings = {}

    if jsondata then
        local res, strs = pcall(json.decode, jsondata)
        if res then
            strings = strs
        end
    end

    for modname, stringlist in pairs(stringsToLocalize) do
        if not strings[modname] then
            strings[modname] = {}
        end

        for k, v in pairs(stringlist) do
            strings[modname][k] = v
        end
    end

    jsondata = json.encode(strings)
    fsobj:write("localization.json", jsondata)
end)

end

umg.expose("localization", localization)
