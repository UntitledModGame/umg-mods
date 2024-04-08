
local Plot = require("shared.Plot")

local ScreenElement = require("client.ScreenElement")



umg.defineEntityType("lootplot.main:world", {
    init = function(ent)
        ent.plot = Plot(
            ent,
            constants.WORLD_PLOT_SIZE,
            constants.WORLD_PLOT_SIZE
        )
    end,
    
    onCreate = function(ent)
        if client then
            ent.ui = ScreenElement({
                nextRound = function()
                    -- attempts to move to the next round
                end,
                getProgress = function()
                    -- gets the "progress"
                    -- attempts to move to the next round
                end
            })
        end
    end
})


