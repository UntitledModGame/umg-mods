local localization = {}
if false then _G.localization = localization end

local interpolate = require("shared.interpolate")

---@type table<string, table<string, string>>
local stringsToLocalize = {}
---@type table<string, fun(text:string,variables?:table<string,any>,args?:table)>
local localizers = {}
local EXPORT_ON_EXIT = true



---Create new localizer for this specific mod.
function localization.newLocalizer()
    local loadingContext = assert(umg.getLoadingContext(), "this can only be called at load-time")
    local modname = loadingContext.modname
    if localizers[modname] then
        return localizers[modname]
    end

    --- Translates a string.
    ---@param text string String to translate
    ---@param variables table<string, any>? Variable to interpolate
    ---@param args table? Reserved for future use
    ---@return string
    ---@deprecated use localization.newLocalizer instead.
    local function localize(text, variables, args)
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

        return variables and interpolate(text, variables) or text
    end

    localizers[modname] = localize
    return localize
end


---@deprecated use localization.newLocalizer() instead
localization.localize = localization.newLocalizer()

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
