
local objects = {}

local objectsTools = require("shared.tools")
for k,v in pairs(objectsTools) do
    objects[k] = v
end

objects.Class = require("shared.Class");
objects.Set = require("shared.Set");
objects.Array = require("shared.Array");
objects.Heap = require("shared.Heap");
objects.Partition = require("shared.Partition");
objects.Enum = require("shared.Enum")
objects.Color = require("shared.Color")

umg.expose("objects", objects)

