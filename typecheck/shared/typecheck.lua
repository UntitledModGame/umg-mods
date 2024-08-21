

local typecheck = {}


local type = type
local floor = math.floor
local select = select


local types = {}

function types.any()
    return true
end


function types.int(x)
    return (type(x) == "number") and floor(x) == x, "expected integer, (not float!)"
end
types.integer = types.int


function types.num(x)
    return type(x) == "number", "expected number"
end
types.number = types.num


function types.string(x)
    return type(x) == "string", "expected string"
end
types.str = types.string


function types.table(x)
    return type(x) == "table",  "expected table"
end


function types.userdata(x)
    return type(x) == "userdata", "expected userdata"
end


function types.func(x)
    return type(x) == "function", "expected function"
end
types["function"] = types.func
types.fn = types.func


function types.boolean(x)
    return type(x) == "boolean", "expected boolean"
end
types.bool = types.boolean



function types.entity(x)
    return umg.exists(x), "expected entity"
end
types.ent = types.entity



function types.voidEntity(x)
    -- an entity that may or may not exist
    -- (ie an entity thats just been created)
    return umg.isEntity(x), "expected void entity"
end


local allGroup = umg.group()
function types.trueEntity(x)
    --[[
        a "true" entity is an entity that exists in allGroup.
    ]]
    return allGroup:has(x)
end




local function optional(f)
    return function(x)
        return x == nil or f(x)
    end
end


local parseToFunction -- need to define here for mutual recursion


local function parseUnion(str)
    local s = str:find("|")
    local type1 = str:sub(1,s-1)
    local type2 = str:sub(s+1)
    local f1 = parseToFunction(type1)
    local f2 = parseToFunction(type2)
    return function(x)
        local ok1, er1 = f1(x)
        local ok2, er2 = f2(x)
        if ok1 or ok2 then
            return true
        else
            return false, er1 .. " or " .. er2
        end
    end
end


function parseToFunction(str)
    str = str:gsub(" ","")

    if str:find("|") then
        return parseUnion(str)
    elseif str:find("%?") then
        -- if string contains question mark, treat the argument as optional.
        str = str:gsub("%?","")
        local func = parseToFunction(str)
        return optional(func)
    elseif types[str] then
        return types[str]
    end
    umg.melt("malformed typecheck string: " .. tostring(str))
end



-- Must define here for mutual recursion
local makeCheckFunction


local function parseTableType(tableType)
    local keyList = {}
    local valueCheckers = {}

    for key, arg in pairs(tableType) do
        table.insert(keyList, key)
        local er0
        valueCheckers[key], er0 = makeCheckFunction(arg)
        if not valueCheckers[key] then
            umg.melt("Couldn't create typecheck function for key: " .. key .. " : " .. er0)
        end
    end

    local function check(x)
        local typeOk, er1 = types.table(x)
        if not typeOk then
            return nil, er1
        end

        for _, key in ipairs(keyList) do
            local val = x[key]
            local ok, err = valueCheckers[key](val)
            if not ok then
                return nil, "had bad value for '" .. tostring(key) .. "':\n" ..tostring(err)
            end
        end

        return true -- else, we are goods
    end

    return check
end



function makeCheckFunction(arg)
    if type(arg) == "string" then
        return parseToFunction(arg)
    end
    if type(arg) == "table" then
        return parseTableType(arg)
    end
    if type(arg) == "function" then
        return arg
    end
    return nil, tostring(arg) .. " is NOT a valid typecheck value! Must be either function, string, or table"
end



local function parseArgCheckers(arr)
    for i=1, #arr do
        local func, err = makeCheckFunction(arr[i])
        if not func then
            umg.melt(("Failure parsing typecheck arg: %d:\n"):format(i) .. tostring(err))
        end
        arr[i] = func
    end
end



local function makeErr(arg, err, i)
    local estring = "Bad argument " .. tostring(i) .. ":\n"
    local err_data = tostring(type(arg)) .. " was given, but " .. tostring(err) 
    return estring .. err_data
end


function typecheck.assert(...)
    local check_fns = {...}
    parseArgCheckers(check_fns)

    return function(...)
        for i=1, #check_fns do
            local arg = select(i, ...)
            local ok, err = check_fns[i](arg)
            if not ok then
                umg.melt(makeErr(arg, err, i), 3)
            end
        end
    end
end


function typecheck.check(...)
    local check_fns = {...}
    parseArgCheckers(check_fns)

    return function(...)
        for i=1, #check_fns do
            local arg = select(i, ...)
            local ok, err = check_fns[i](arg)
            if not ok then
                return false, makeErr(arg, err, i)
            end
        end
        return true
    end
end



function typecheck.isType(x, typeName)
    assert(types[typeName], "Invalid type!")
    return types[typeName](x)
end



function typecheck.assertKeys(tabl, keys)
    --[[
        asserts that `tabl` is a table, 
        and that it has all of the keys listed in the `keys` table.
    ]]
    if type(tabl) ~= "table" then
        umg.melt("Expected table, got: " .. type(tabl), 2)
    end
    for _, key in ipairs(keys) do
        if tabl[key] == nil then
            umg.melt("Missing key: " .. tostring(key), 2)
        end
    end

end



local addTypeTc = typecheck.assert("string", "function")
function typecheck.addType(typeName, check)
    addTypeTc(typeName, check)
    assert(not types[typeName], "Overwriting existing type!")

    types[typeName] = check
end

-- LOVE types
local loveTypes = {
    "ImageData",
    "Source",
    "Texture",
    "Transform",
    "Quad",
}
for _, lt in ipairs(loveTypes) do
    local errmsg = "Expected "..lt.." LOVE object"
    typecheck.addType("love:"..lt, function(x)
        local ok = not not (type(x) == "userdata" and x.typeOf and x:typeOf(lt))
        return ok, errmsg
    end)
end

typecheck.addType("love", function(x)
    local ok = not not (type(x) == "userdata" and x.typeOf and x:typeOf("Object"))
    return ok, "Expected LOVE object"
end)

return typecheck
