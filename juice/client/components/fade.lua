


local fadeGroup = umg.group("fade")


local function getValue(ent, fade)
    if fade.getValue then
        local val = fade.getValue(ent)
        if val then return val end
    end
    if fade.value then
        return fade.value
    end
    if fade.component then
        return ent[fade.component]
    end
end


local function updateOpacity(ent)
    local fade = ent.fade

    local value = getValue(ent, fade) or 1
    local mult = fade.multiplier or 1
    ent.opacity = value * mult
end


umg.on("@update", function()
    for _, ent in ipairs(fadeGroup) do
        updateOpacity(ent)
    end
end)


