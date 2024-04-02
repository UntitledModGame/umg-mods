
local Plot = require("shared.Plot")


umg.defineEntityType("lootplot:world", {
    init = function(ent)
        ent.plot = Plot(
            ent,
            constants.WORLD_PLOT_SIZE,
            constants.WORLD_PLOT_SIZE
        )
    end
})


