local localization = {}
if false then _G.localization = localization end

local interpolate = require("shared.interpolate")

---@type table<string, table<string, string>>
local stringsToLocalize = {}
---@type table<string, localization.Interpolator>
local interpolators = {}
local EXPORT_ON_EXIT = true



---@class localization.Interpolator: objects.Class
local Interpolator = objects.Class("localization:Interpolator")

---@param modname string
---@param text string
function Interpolator:init(modname, text, context)
    self.modname = modname
    self.text = text

    --[[
    dummy for now.
    In future, add proper translation
    ]]
    if not stringsToLocalize[modname] then
        stringsToLocalize[modname] = {}
    end

    if EXPORT_ON_EXIT and not stringsToLocalize[modname][text] and client then
        client.send("localization:cache", modname, text)
    end
    stringsToLocalize[modname][text] = text
end

---@param variables table<string, any>? Variable to interpolate
function Interpolator:__call(variables)
    return variables and interpolate(self.text, variables) or self.text
end

function Interpolator:__tostring()
    return self.text
end



---@param text string String to translate
---@param context table? Reserved for future use
---@return localization.Interpolator|fun(variables:table<string,any>?):string
function localization.newInterpolator(text, context)
    local loadingContext = assert(umg.getLoadingContext(), "this can only be called at load-time")
    local key = loadingContext.modname.."\0"..text
    local interpolator = interpolators[key]

    if not interpolator then
        interpolator = Interpolator(loadingContext.modname, text)
        interpolators[key] = interpolator
    end

    return interpolator
end


---Create new localizer for this specific mod.
---@deprecated replaced by `localization.newInterpolator` and `localization.localize`.
function localization.newLocalizer()
    return localization.localize
end


--- Translates a string.
---@param text string String to translate
---@param variables table<string, any>? Variable to interpolate
---@param context table? Reserved for future use
---@return string
function localization.localize(text, variables, context)
    return localization.newInterpolator(text, context)(variables)
end



-- TODO: Rectify this code once we have client-side saving.
if EXPORT_ON_EXIT then

umg.definePacket("localization:cache", {typelist = {"string", "string"}})

if server then
    server.on("localization:cache", function(_, modname, text)
        if not stringsToLocalize[modname] then
            stringsToLocalize[modname] = {}
        end
        stringsToLocalize[modname][text] = text
    end)

    umg.on("@quit", function()
        local fsobj = server.getSaveFilesystem()
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

end

umg.expose("localization", localization)
