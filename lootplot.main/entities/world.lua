

umg.defineEntityType("lootplot.main:world", {
    init = function(ent)
        ent.plot = lp.Plot(
            ent,
            constants.WORLD_PLOT_SIZE,
            constants.WORLD_PLOT_SIZE
        )
    end
})


