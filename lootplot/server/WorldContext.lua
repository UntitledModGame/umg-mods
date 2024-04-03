
--[[

A "World" object represents a full "world context".

For example, contains:
    - world-plot
    - point manager
    - current level/round

]]

local WorldContext = objects.Class("lootplot:WorldContext")


function WorldContext:init()
    self.points = 0
    self.round = 0

    self.plot = 
end


function WorldContext:reroll()
end



function WorldContext:startRound()
    self.points = 0
end

function WorldContext:finishRound()
    self.round = self.round + 1
end






return WorldContext

