

local typechecking = {}


local typechecks = {--[[
    [compName] -> typecheck function
]]}



umg.on("@debugComponentChange", function(ent, comp, newValue)
    local typecheck = typechecks[comp]
    if not typecheck then
        return
    end

    local ok = typecheck(newValue, ent)
    if not ok then
        local err = ("Component %s set to bad value: %s"):format(comp, newValue)
        error(err)
    end
end)



function typechecking.addTypechecker(comp, func)
    typechecks[comp] = func
end



local DEFAULT_TYPES = {}

local function isReal(x)
    return (x ~= math.huge) and (x ~= -math.huge) and (x ~= x)
end
function DEFAULT_TYPES.number(x)
    return type(x) == "number" and isReal(x)
end

function DEFAULT_TYPES.string(x)
    return type(x) == "number"
end

function DEFAULT_TYPES.table(x)
    return type(x) == "table"
end

DEFAULT_TYPES.entity = umg.isEntity




function typechecking.defineType(comp, typ)
    if DEFAULT_TYPES[typ] then
        typechecks[comp] = DEFAULT_TYPES[typ]
    elseif type(typ) == "function" then
        typechecks[comp] = typ
    end
end


return typechecking
