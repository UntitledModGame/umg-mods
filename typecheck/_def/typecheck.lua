---@meta

typecheck = {}

---@return boolean
function typecheck.any()
end

---@param x any
---@return boolean, string
function typecheck.int(x)
end
typecheck.integer = typecheck.int


---@param x any
---@return boolean, string
function typecheck.num(x)
end
typecheck.number = typecheck.num

---@param x any
---@return boolean, string
function typecheck.string(x)
end
typecheck.str = typecheck.string

---@param x any
---@return boolean, string
function typecheck.table(x)
end

---@param x any
---@return boolean, string
function typecheck.userdata(x)
end

---@param x any
---@return boolean, string
function typecheck.func(x)
end
typecheck["function"] = typecheck.func
typecheck.fn = typecheck.func

---@param x any
---@return boolean, string
function typecheck.boolean(x)
end
typecheck.bool = typecheck.boolean

---@param x any
---@return boolean, string
function typecheck.entity(x)
end
typecheck.ent = typecheck.entity

---an entity that may or may not exist
---(ie an entity thats just been created)
---@param x any
---@return boolean, string
function typecheck.voidEntity(x)
end


---a "true" entity is an entity that exists in allGroup.
---@param x any
---@return boolean, string
function typecheck.trueEntity(x)
end

---@param f fun(x:any):boolean
---@return fun(x:any?):boolean
function typecheck.optional(f)
end

---@param ... string
---@return fun(...:any)
function typecheck.assert(...)
end

---@param ... string
---@return fun(...:any):(boolean,string?)
function typecheck.check(...)
end

---@generic T
---@param tabl table<T, any>
---@param keys T[]
function typecheck.assertKeys(tabl, keys)
end

---@param typeName string
---@param check fun(x:any):(boolean,string?)
function typecheck.addType(typeName, check)
end

return typecheck
