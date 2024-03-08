

local components = {}


local projectRegular = require("shared.projectRegular")
local projectShared = require("shared.projectShared")


components.projectRegular = projectRegular
components.projectShared = projectShared


function components.project(srcComp, targetComp, value)
    projectRegular(srcComp, targetComp, value)
    projectShared(srcComp, targetComp, value)
end


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

