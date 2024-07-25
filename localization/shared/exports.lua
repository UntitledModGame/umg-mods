
local localization = {}


function localization.localize(text)
    --[[
    dummy for now.
    In future, add proper translation
    ]]
    return text
end

function localization.localizef(text)
    --[[
        localizes text, but ignores everything inside `{}` brackets.
    ]]
    return text
end


umg.expose("localization", localization)
