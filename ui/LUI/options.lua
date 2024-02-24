

local options = {}


local optionDefaults = {--[[
    [opt] -> value or func
]]}

local validOptions = {--[[
    [opt] -> true
]]}


function options.getDefaultValue(opt, elem)
    local default = optionDefaults[opt]
    if type(default) == "function" then
        return default(elem, opt)
    else
        return default
    end
end



local defineOptionTc = typecheck.assert("string")
function options.defineOption(opt, default)
    defineOptionTc(opt, default)
    if optionDefaults[opt] then
        error("Overwriting option!")
    end
    optionDefaults[opt] = default
    validOptions[opt] = true
end



function options.isValidOption(opt)
    return validOptions[opt]
end



return options

