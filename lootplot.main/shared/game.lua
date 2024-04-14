
--[[

Main Context.

points are shared between all players.
money is also shared between all players.

Objective:
Kill the loot-monster.

]]

local Context = objects.Class("lootplot.main:Context")





--[[
    *kinda* hacky, shitty packets here.
    OH WELL! :--)
]]
umg.definePacket("lootplot.main:nextRound", {
    typelist = {}
})
if server then
    server.on("lootplot.main:nextRound", function()
        -- trust the client :shrug:
        local ctx = lp.getContext()
        ctx:nextRound()
    end)
end




function Context:sync(field, value)
    assert(server, "?")
    server.broadcast("lootplot.main:syncContextField", field, value)
end


function Context:setRound()
end
function Context:getRound()
end



function Context:nextRound()
    -- Progresses to next round.
    assert(server,"wot wot")

    umg.call("lootplot.main:startRound")

    -- activate all slots:
    lp.Bufferer()
        :all()
        :slots() -- ppos-->slot
        :execute(function(slotEnt)
            lp.activate(slotEnt)
        end)

    -- TODO: Give reward-money at end of round

    self.round = self.round + 1
    umg.call("lootplot.main:finishRound")

    if self.points > self.requiredPoints then
        -- win condition!!
        -- (upgrade level of loot-monster)
    end
end


function Context:nextRound()
    client.send("lootplot.main:nextRound")
end



function Context:init()
    self.money = 0

    self.round = 0 -- how many "turns" the player has taken

    self.level = 0 -- how many loot-monsters the player has killed

    self.points = 0
    self.requiredPoints = 100

    self.worldEnt = nil
end




local constants = require("shared.constants")

local function createWorld()
    local worldEnt = server.entities.world()
    worldEnt.x = 0
    worldEnt.y = 0

    worldEnt.plot = lp.Plot(
        worldEnt, 
        constants.WORLD_PLOT_SIZE, 
        constants.WORLD_PLOT_SIZE
    )

    worldEnt.data = {
        money = constants.STARTING_MONEY,
        points = constants.STARTING_POINTS,
        round = constants.STARTING_ROUND,
    }

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



function Context:start()
    local worldEnt = createWorld(self)
    addBaseSlots(worldEnt)
    addShopSlots(worldEnt)
    self.worldEnt = worldEnt
end



function Context:playerJoin(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end


function lp.overrides.setPoints(ent, x)
    points = x
end
function lp.overrides.getPoints(ent)
    return points
end

function lp.overrides.setMoney(ent, x)
    money = x
end
function lp.overrides.getMoney(ent)
    return money
end



return Context
