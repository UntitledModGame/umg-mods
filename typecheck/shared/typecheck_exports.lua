
local SHOULD_TEST = false --true
if SHOULD_TEST then
    require("shared._typecheck_tests")
    umg.log.debug("all tests passed")
end



umg.expose("typecheck", require("shared.typecheck"))

