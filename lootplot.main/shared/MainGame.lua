
--[[

Override of Game.

points are shared between all players.
money is also shared between all players.

Objective:
Kill the loot-monster.

]]

local MainGame = objects.Class("lootplot.main:MainGame")





--[[
    *kinda* hacky, shitty code right here.
    OH WELL! :--)
]]
umg.definePacket("lootplot.main:nextRound", {
    arguments = {}
})
if server then
    server.on("lootplot.main:nextRound", function()
        local game = lp.getGame()
        game:nextRound()
    end)
end



if server then

function MainGame:nextRound()
    -- Progresses to next round.
    assert(server,"wot wot")

    umg.call("lootplot.main:startRound")

    -- activate slots:
    --[[
        TODO: should we be doing other shit here?
    ]]
    self.worldEnt.plot:foreachSlot(function(slotEnt, ppos)
        lp.buffer(ppos, function()
            lp.activate(slotEnt)
        end)
    end)

    self.round = self.round + 1
    umg.call("lootplot.main:finishRound")
end

else

function MainGame:nextRound()
    client.send("lootplot.main:nextRound")
end

end


function MainGame:init()
    self.money = 0

    self.points = 0
    self.requiredPoints = 100

    self.worldEnt = nil

    if client then
        setupUI(self)
    end
end




local function createWorld()
    local worldEnt = server.entities.world()
    worldEnt.x = 0
    worldEnt.y = 0
    worldEnt.plot = lp.Plot(
        worldEnt, 
        constants.WORLD_PLOT_SIZE, constants.WORLD_PLOT_SIZE
    )
    return worldEnt
end


local function addBaseSlots(worldEnt)
    -- adds basic slots to be overridden
    local worldPlot = worldEnt.plot
    local grid = worldPlot.plot.grid
    local plot = worldPlot.plot
    grid:foreachInArea(8,11, 3,6, function(val, x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({slot=i, plot=plot})

        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
    end)
end

local function addShopSlots(worldEnt)
    local worldPlot = worldEnt.plot
    local grid = worldPlot.plot.grid
    local plot = worldPlot.plot
    grid:foreachInArea(3,6, 3,6, function(val, x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({slot=i, plot=plot})

        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
    end)
end



function MainGame:start()
    local worldEnt = createWorld()
    addBaseSlots(worldEnt)
    addShopSlots(worldEnt)
    self.worldEnt = worldEnt
end



function MainGame:playerJoin(clientId)
    local p =server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end


function MainGame:setPoints(ent, x)
    self.points = x
end
function MainGame:getPoints(ent)
    return self.points
end

function MainGame:setMoney(ent, x)
    self.money = x
end
function MainGame:getMoney(ent)
    return self.money
end



return MainGame
