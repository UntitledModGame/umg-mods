---@meta
local objects = {}

local objectsTools = require("shared.tools")
for k,v in pairs(objectsTools) do
    objects[k] = v
end

objects.Class = require("shared.Class")
objects.Set = require("shared.Set")
objects.Array = require("shared.Array")
objects.Heap = require("shared.Heap")
objects.Enum = require("shared.Enum")
objects.Color = require("shared.Color")
objects.Grid = require("shared.Grid")

---An empty table. DO NOT MODIFY!!!
---(Used as default arguments and such)
---
---Availability: Client and Server
objects.EMPTY = {}


if server then
    ---Availability: **Server**
    objects.emptyEntity = function()
        return server.entities.empty()
    end
end


--- Checks if a value is callable
---@param x any
---@return boolean
function objects.isCallable(x)
    if type(x) == "function" then
        return true
    end
    local mt = getmetatable(x)
    return mt and mt.__call
end


if false then
    ---Provides functionality to common data structures.
    ---
    ---Availability: Client and Server
    _G.objects = objects
end
umg.expose("objects", objects)
return objects
