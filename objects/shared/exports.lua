---@meta


---Provides functionality to common data structures.
---
---Availability: Client and Server
---@class objects.mod
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

if false then
    _G.objects = objects
end
umg.expose("objects", objects)
return objects
