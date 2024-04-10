
local Plot = require("shared.Plot")



umg.defineEntityType("lootplot.main:world", {
    init = function(ent)
        ent.plot = Plot(
            ent,
            constants.WORLD_PLOT_SIZE,
            constants.WORLD_PLOT_SIZE
        )
    end
})


