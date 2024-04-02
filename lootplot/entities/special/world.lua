
local Plot = require("shared.Plot")


umg.defineEntityType("lootplot:world", {
    worldPlot = {
        x = 0,
        y = 0
    },

    init = function(ent)
        ent.plot = Plot(
            ent,
            constants.WORLD_PLOT_SIZE
        )
    end
})


