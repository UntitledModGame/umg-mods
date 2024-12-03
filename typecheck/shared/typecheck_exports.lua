
local SHOULD_TEST = false --true
if SHOULD_TEST then
    require("shared._typecheck_tests")
    umg.log.debug("all tests passed")
end


local typecheck = require("shared.typecheck")

if false then
    _G.typecheck = typecheck
end

umg.expose("typecheck", typecheck)
