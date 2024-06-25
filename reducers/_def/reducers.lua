---@meta

reducers = {}

---@param a boolean
---@param b boolean
---@return boolean
function reducers.OR(a,b)
end

---@param a boolean
---@param b boolean
---@return boolean
function reducers.AND(a,b)
end

---takes two inputs a,b
---returns the one that is a valid umg entity.
---@param a any
---@param b any
---@return any
function reducers.EXISTS(a, b)
end

---TODO: Should we have the defaults (or 0) here?
---It's (slightly) less efficient.
---@param a number
---@param b number
---@return number
function reducers.ADD(a,b)
end
reducers.SUM = reducers.ADD


---TODO: Should we have the defaults (or 1) here?
---It's (slightly) less efficient.
---@param a number
---@param b number
---@return number
function reducers.MULTIPLY(a,b)
end

---combines vectors together by adding.
---(Answers must return 2 numbers)
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@return number,number
function reducers.ADD_VECTOR(x1,x2, y1,y2)
end

---combines 3d vectors together by adding.
---(Answers must return 3 numbers)
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@param z1 number
---@param z2 number
---@return number,number,number
function reducers.ADD_VECTOR3(x1,x2, y1,y2, z1,z2)
end

---combines vectors together by multiplying.
---(Only works when the answers return 2 numbers.)
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@return number,number
function reducers.MULTIPLY_VECTOR(x1,x2, y1,y2)
end

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
---@param a any
---@param b any
---@param prio_a number
---@param prio_b number
---@return any,number
function reducers.PRIORITY(a, b, prio_a, prio_b)
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
---@param x1 any
---@param x2 any
---@param y1 any
---@param y2 any
---@param prio_1 integer
---@param prio_2 integer
---@return any,any,integer
function reducers.PRIORITY_DOUBLE(x1,x2, y1,y2, prio_1, prio_2)
end
reducers.MIN = math.min
reducers.MAX = math.max

---@generic T
---@param arr_a T[]
---@param arr_b T[]
---@return T[]
function reducers.MERGE_ARRAYS(arr_a, arr_b)
end

---returns the FIRST truthy result
---(This will be the first umg.answer that is loaded)
---@param a any
---@param b any
---@return any
function reducers.FIRST(a, b)
end


---returns the LAST truthy result
---(This will be the last umg.answer that is loaded)
---@param a any
---@param b any
---@return any
function reducers.LAST(a, b)
end

---Reducer function that collects all single inputs into an array.

---The way this works, is the first argument `a` is treated
---as an array.
---`a` is then continuously passed to the next arguments.
---@generic T
---@param a T|T[]
---@param b T
---@return T[]
function reducers.SINGLE_COLLECT(a, b)
end

return reducers
