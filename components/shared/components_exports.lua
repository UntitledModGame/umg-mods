

local components = {}

components.project = require("shared.project_component")


local typechecking = require("shared.typechecking")

function components.defineComponent(comp, options)
    if options.type then
        typechecking.defineType(comp, options.type)
    end
    --[[
        todo: add other shit here
    ]]
end


umg.expose("components", components)

