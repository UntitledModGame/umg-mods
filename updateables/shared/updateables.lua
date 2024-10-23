local event, name

if server then
    event, name = "@tick", "onUpdateServer"
else
    event, name = "@update", "onUpdateClient"
end

local group = umg.group(name)

umg.on(event, function(dt)
    for _, ent in ipairs(group) do
        ent[name](ent, dt)
    end
end)
