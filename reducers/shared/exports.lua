
---Availability: Client and Server
---@class reducers.mod
local reducers = {}
--[[

These are mainly supposed to be used with the umg.ask() function,
as the reducer.

]]

---Availability: Client and Server
---@param a boolean
---@param b boolean
---@return boolean
function reducers.OR(a,b)
    return a or b
end

---Availability: Client and Server
---@param a boolean
---@param b boolean
---@return boolean
function reducers.AND(a,b)
    return a and b
end

---takes two inputs a,b
---returns the one that is a valid umg entity.
---
---Availability: Client and Server
---@param a any
---@param b any
---@return any
function reducers.EXISTS(a, b)
    if umg.exists(a) then
        return a
    end
    return b
end

---TODO: Should we have the defaults (or 0) here?
---It's (slightly) less efficient.
---
---Availability: Client and Server
---@param a number
---@param b number
---@return number
function reducers.ADD(a,b)
    return (a or 0) + (b or 0)
end
reducers.SUM = reducers.ADD


---TODO: Should we have the defaults (or 1) here?
---It's (slightly) less efficient.
---
---Availability: Client and Server
---@param a number
---@param b number
---@return number
function reducers.MULTIPLY(a,b)
    return (a or 1) * (b or 1)
end

---combines vectors together by adding.
---(Answers must return 2 numbers)
---
---Availability: Client and Server
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@return number,number
function reducers.ADD_VECTOR(x1,x2, y1,y2)
    return x1 + x2, y1 + y2
end

---combines 3d vectors together by adding.
---(Answers must return 3 numbers)
---
---Availability: Client and Server
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@param z1 number
---@param z2 number
---@return number,number,number
function reducers.ADD_VECTOR3(x1,x2, y1,y2, z1,z2)
    return x1 + x2, y1 + y2, z1+z2
end

---combines vectors together by multiplying.
---(Only works when the answers return 2 numbers.)
---
---Availability: Client and Server
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@return number,number
function reducers.MULTIPLY_VECTOR(x1,x2, y1,y2)
    return x1 * x2, y1 * y2
end

-- default priority
local D_PRIO = -9999

---Treats the 2nd answer-value as the priority.
---Returns the answer with the highest priority.
---
---The first argument can be any type- only the priority matters for resolution.
---
---(If priorities are equal, returns the most recently defined answer)
---
---If you want a definitive answer to a question, 
---(i.e. a question where results can't really be combined,)
---this is probably the best reducer to use.
---
---Example:
---```lua
----- answering image for an entity:
---umg.answer("modname:getImage", function(ent)
---    if ent.animation then
---        -- return
---        local img = ent.animation.frame
---        local priority = 1
---        return img, priority
---    end
---end)
---```
---
---Availability: Client and Server
---@param a any
---@param b any
---@param prio_a number
---@param prio_b number
---@return any,number
function reducers.PRIORITY(a, b, prio_a, prio_b)
    if (prio_a or D_PRIO) > (prio_b or D_PRIO) then
        return a, prio_a
    end
    return b, prio_b
end


---same as PRIORITY, but for 2 arguments, not 1.
---
---Argument visualization:
---```lua
---umg.answer(... function()
---    return x1, y1, prio_1
---end)
---
---umg.answer(... function()
---    return x2, y2, prio_2
---end)
---```
---
---Availability: Client and Server
---@param x1 any
---@param x2 any
---@param y1 any
---@param y2 any
---@param prio_1 integer
---@param prio_2 integer
---@return any,any,integer
function reducers.PRIORITY_DOUBLE(x1,x2, y1,y2, prio_1, prio_2)
    if (prio_1 or D_PRIO) > (prio_2 or D_PRIO) then
        return x1, y1, prio_1
    end
    return x2, y2, prio_2
end


---Thin wrapper to `math.min`
---
---Availability: Client and Server
---@param a number
---@param b number
---@return number
function reducers.MIN(a, b)
    return math.min(a, b)
end

---Thin wrapper to `math.max`
---
---Availability: Client and Server
---@param a number
---@param b number
---@return number
function reducers.MAX(a, b)
    return math.max(a, b)
end



local UNIQUE_MT = {}

---Availability: Client and Server
---@generic T
---@param arr_a T[]
---@param arr_b T[]
---@return T[]
function reducers.MERGE_ARRAYS(arr_a, arr_b)
    assert(type(arr_a) == "table", "Should be a table!")
    assert(type(arr_b) == "table", "Should be a table!")

    local new = {}
    for i=1, #arr_a do
        table.insert(new, arr_a[i])
    end
    for i=1, #arr_b do
        table.insert(new, arr_b[i])
    end
    return new
end

---returns the FIRST truthy result
---(This will be the first umg.answer that is loaded)
---
---Availability: Client and Server
---@param a any
---@param b any
---@return any
function reducers.FIRST(a, b)
    if a then
        return a
    end
    return b
end


---returns the LAST truthy result
---(This will be the last umg.answer that is loaded)
---
---Availability: Client and Server
---@param a any
---@param b any
---@return any
function reducers.LAST(a, b)
    if b then
        return b
    end
    return a
end

---Reducer function that collects all single inputs into an array.
---
---The way this works, is the first argument `a` is treated
---as an array.
---`a` is then continuously passed to the next arguments.
---
---Availability: Client and Server
---@generic T
---@param a T|T[]
---@param b T
---@return T[]
function reducers.SINGLE_COLLECT(a, b)
    local ret = a

    if getmetatable(ret) ~= UNIQUE_MT then
        --[[
        this is kinda hacky lmao!
        Basically, we need to be able to add any type to the array.
        So we set a unique metatable (UNIQUE_MT)
        ]]
        ret = setmetatable({}, UNIQUE_MT)
        if a ~= nil then
            table.insert(ret, a)
        end
    end

    if b ~= nil then
        table.insert(ret, b)
    end

    return ret
end



if false then
    _G.reducers = reducers
end
umg.expose("reducers", reducers)
return reducers
