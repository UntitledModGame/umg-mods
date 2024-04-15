
--[[

Main Context.

points are shared between all players.
money is also shared between all players.

Objective:
Kill the loot-monster.

]]


local Context = objects.Class("lootplot.main:Context")


local currentContext = nil


local lpWorldGroup = umg.group("lootplotContext")
lpWorldGroup:onAdded(function(ent)
    if not currentContext then
        currentContext = ent.context
    else
        -- TODO: change this to a log, as opposed to a print
        print("WARNING::: Duplicate lootplot.main context created!!")
    end
end)


umg.definePacket("lootplot.main:syncWorldField", {
    typelist = {"entity", "string", "number"}
})
local FIELDS = {
    money=true, 
    points=true,requiredPoints=true,
    level=true, round=true
}


function Context:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent

    self.money = constants.STARTING_MONEY
    self.points = constants.STARTING_POINTS
    self.round = constants.STARTING_ROUND
    self.level = constants.STARTING_LEVEL
    self.requiredPoints = 0
end


function Context:syncAll()
    for field, _ in pairs(FIELDS) do
        self:sync(field)
    end
end


function Context:sync(field)
    assert(server, "This function can only be called on server-side.")
    if not FIELDS[field] then
        error("Invalid field: " .. field)
    end
    server.broadcast("lootplot.main:syncWorldField", self.ownerEnt, field, self[field])
end

if client then
    client.on("lootplot.main:syncWorldField", function(ent, field, val)
        ent.context[field] = val
    end)
end




umg.defineEntityType("lootplot.main:world", {})





local constants = require("shared.constants")

local function createWorld()
    local wEnt = server.entities.world()
    wEnt.x = 0
    wEnt.y = 0

    wEnt.plot = lp.Plot(
        wEnt, 
        constants.WORLD_PLOT_SIZE, 
        constants.WORLD_PLOT_SIZE
    )

    -- the reason we save Context inside an entity,
    -- is because if we go to save the world, the world-data will be
    -- saved alongside the world-entity.
    wEnt.lootplotContext = Context(wEnt)
    return wEnt
end


--[[
==============================
    World-generation code:
==============================
]]
local function addBaseSlots(plot)
    -- adds basic slots to be overridden
    local grid = plot.grid
    grid:foreachInArea(8,11, 3,6, function(val, x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({slot=i, plot=plot})

        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
    end)
end
local function addShopSlots(plot)
    local grid = plot.grid
    grid:foreachInArea(3,6, 3,6, function(val, x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({slot=i, plot=plot})

        local basicSlot = server.entities.slot()
        lp.setSlot(ppos, basicSlot)
    end)
end





umg.on("@createWorld", function()
    local ent = createWorld()
    addBaseSlots(ent.plot)
    addShopSlots(ent.plot)
end)



umg.on("@playerJoin", function(clientId)
    local p = server.entities.player(clientId)
    p.x,p.y = 200, 100
    p.moveX, p.moveY = 0,0
end)



if server then
function lp.overrides.setPoints(ent, x)
    currentContext:set("points", x)
end
function lp.overrides.setMoney(ent, x)
    currentContext:set("money", x)
end
end

function lp.overrides.getPoints(ent)
    return currentContext.points
end
function lp.overrides.getMoney(ent)
    return currentContext.money
end



return Context


