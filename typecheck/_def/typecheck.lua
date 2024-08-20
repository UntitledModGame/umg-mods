---@meta

typecheck = {}

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

---@param x any
---@param typeName string
function typecheck.isType(x, typeName)
end


return typecheck
