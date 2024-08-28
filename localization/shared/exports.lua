local localization = {}
if false then _G.localization = localization end

local interpolate = require("shared.interpolate")

---@type table<string, table<string, string>>
local stringsToLocalize = {}
---@type table<string, fun(text:string,variables?:table<string,any>,args?:table)>
local localizers = {}


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

        stringsToLocalize[modname][text] = text

        return variables and interpolate(text, variables) or text
    end

    localizers[modname] = localize
    return localize
end


---@deprecated use localization.newLocalizer() instead
localization.localize = localization.newLocalizer()

function localization.exportAll()
    -- TODO: Support client.
    if server then
        local result, jsondata = pcall(server.load, "localization.json")
        local strings

        if result then
            strings = json.decode(jsondata)
        else
            strings = {}
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
        server.save("localization.json", jsondata)
    end
end


umg.expose("localization", localization)
