---@meta

input = {}

---@param args? {priority?:integer}
---@return input.InputListener
function input.InputListener(args)
end

---TODO: provide support for controllers in future here.
---
---We should probably create a separate module for the pointer...?
---Because we want to add a TONNE of flexibility.
---@return number,number
function input.getPointerPosition()
end

---@param controls string[]
function input.defineControls(controls)
end

---@param controls table<string, string[]>
function input.setControls(controls)
end

---@param x any
---@return boolean
function input.isValidControl(x)
end

return input
