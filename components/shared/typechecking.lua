

local typechecking = {}


local typechecks = {--[[
    [compName] -> typecheck function
]]}



umg.on("@debugComponentChange", function(ent, comp, newValue)
    local typecheck = typechecks[comp]
    if not typecheck then
        return
    end

    typecheck(newValue, ent)
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

function typechecking.defineComponent(comp, typ)
    
end


return typechecking
