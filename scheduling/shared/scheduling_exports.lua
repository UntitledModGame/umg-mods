
local scheduling = {}


scheduling.delay = require("shared.delay")

scheduling.nextTick = require("shared.next_tick")

scheduling.skip = require("shared.skip")


umg.expose("scheduling", scheduling)
