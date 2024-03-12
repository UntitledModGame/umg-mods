
local objects = {}

local objectsTools = require("shared.tools")
for k,v in pairs(objectsTools) do
    objects[k] = v
end

objects.Class = require("shared.Class");
objects.Set = require("shared.Set");
objects.Array = require("shared.Array");
objects.Heap = require("shared.Heap");
objects.Enum = require("shared.Enum")
objects.Color = require("shared.Color")

objects.EMPTY = {}
-- An empty table. DO NOT MODIFY!!!
-- (Used as default arguments and such)


if server then
    objects.emptyEntity = function()
        return server.entities.empty()
    end
end

umg.expose("objects", objects)

