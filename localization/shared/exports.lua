
local localization = {}


function localization.localize(text)
    --[[
    dummy for now.
    In future, add proper translation
    ]]
    return text
end

function localization.localizef(text, variables)
    --[[
        localizes text, 
        and interpolates all variables inside %{name} brackets.
    ]]
    return text
end


umg.expose("localization", localization)
