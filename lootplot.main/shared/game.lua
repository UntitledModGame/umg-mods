
--[[

Main Context.

points are shared between all players.
money is also shared between all players.

Objective:
Kill the loot-monster.

]]





umg.definePacket("lootplot.main:nextRound", {
    typelist = {}
})

local nextRound
if server then

function nextRound()
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

-- Just trust the client :shrug:
server.on("lootplot.main:nextRound", nextRound)

else

function nextRound()
    client.send("lootplot.main:nextRound")
end

end





umg.defineEntityType("lootplot.main:world", {
    lootplotWorld = true 
    -- smol, hacky component to uniquely identify this entity
})



local lpWorldGroup = umg.group("lootplotWorld")
local function get(field)
    -- this is pretty darn hacky and bad.
    local worldEnt = lpWorldGroup[1]
    if worldEnt then
        return worldEnt.data[field]
    end
    return 0
end


local function sync(field, value)
    assert(server, "?")
    local worldEnt = getWorld()
    server.broadcast("lootplot.main:syncContextField", field, value)
end





local function init()
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

    --[[
        the reason we save world-data inside the entity,
        is because if we go to save the world, the world-data will be
        saved alongside the world-entity.
    ]]
    worldEnt.data = {
        money = constants.STARTING_MONEY,
        points = constants.STARTING_POINTS,
        round = constants.STARTING_ROUND,
        level = constants.STARTING_LEVEL
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




local worldEnt = nil

umg.on("@createWorld", function()
    worldEnt = createWorld(self)
    addBaseSlots(worldEnt)
    addShopSlots(worldEnt)
end)



umg.on("@playerJoin", function(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end)




if server then
function lp.overrides.setPoints(ent, x)
    data.points = x
end
function lp.overrides.setMoney(ent, x)
    data.money = x
end
end

function lp.overrides.getPoints(ent)
    return data.points
end
function lp.overrides.getMoney(ent)
    return data.money
end


