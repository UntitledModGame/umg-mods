


local positions = {}



local options = require("shared.options")



local setOptionTc = typecheck.assert("string")

function positions.setOption(key, val)
    setOptionTc(key, val)
    options.setOption(key,val)
end


function positions.getOption(key)
    return options[key]
end



components.defineComponent("x", {
    type = "number"
})

components.defineComponent("y", {
    type = "number"
})





umg.expose("positions", positions)

