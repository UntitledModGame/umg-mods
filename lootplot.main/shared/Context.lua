
--[[

Context:

There is one "Context" object when a lootplot game is running.
(The "Context" object belongs to the worldEnt)

----------------------------------

points are shared between all players.
money is also shared between all players.

Objective:
Get enough points to kill the loot-monster.


]]

---@class lootplot.Context: objects.Class
local Context = objects.Class("lootplot.main:Context")


umg.definePacket("lootplot.main:syncContextValue", {
    typelist = {"entity", "string", "number"}
})
local VALUES = {
    money=true,
    combo=true,
    points=true,
    level=true,
}

function Context:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent
    assert(ent.plot, "Needs a plot!")

    local constants = lp.main.constants
    self.combo = 0
    self.level = 1
    self.money = constants.STARTING_MONEY
    self.points = constants.STARTING_POINTS

    -- doomClock is integral to lootplot.main gamemode,
    -- since it tracks the current round/level.
    self.doomClockEntity = nil
end


function Context:setDoomClock(ent)
    self.doomClockEntity = ent
end

function Context:getDoomClock()
    return self.doomClockEntity
end



function Context:sync()
    -- syncs everything:
    assert(server,"?")
    for field, _ in pairs(VALUES) do
        self:syncValue(field)
    end
end

function Context:tick()
    local plot = self:getPlot()
    plot:tick()
end

---@return lootplot.Plot
function Context:getPlot()
    return self.ownerEnt.plot
end


function Context:syncValue(key)
    assert(server, "This function can only be called on server-side.")
    if not VALUES[key] then
        error("Invalid key: " .. key)
    end
    server.broadcast("lootplot.main:syncContextValue", self.ownerEnt, key, self[key])
end

if client then
    client.on("lootplot.main:syncContextValue", function(ent, field, val)
        ent.lootplotContext[field] = val
    end)
end



if server then

--[[
points are shared between all players.
money is also shared between all players.
]]
function Context:setPoints(ent, x)
    self.points = x
    self:syncValue("points")
end

function Context:setMoney(ent, x)
    self.money = x
    self:syncValue("money")
end

function Context:setCombo(ent, x)
    self.combo = x
    self:syncValue("combo")
end

function Context:setLevel(ent, x)
    self.level = x
    self:syncValue("level")
end

end -- if server

function Context:getPoints(ent)
    return self.points
end

function Context:getMoney(ent)
    return self.money
end

function Context:getCombo(ent)
    return self.combo
end

function Context:getLevel(ent)
    return self.level
end



-- Pipeline multipler
umg.definePacket("lootplot.main:setSpeedMultipler", {typelist = {"number"}})
local currentMultipler = 1

---@param mult number
function Context:setSpeedMultipler(mult)
    if server then
        currentMultipler = mult
    else
        client.send("lootplot.main:setSpeedMultipler", mult)
    end
end

if server then

server.on("lootplot.main:setSpeedMultipler", function(clientId, value)
    if server.getHostClient() == clientId then
        currentMultipler = value
    end
end)

umg.answer("lootplot:getPipelineDelayMultiplier", function()
    return 1 / currentMultipler
end)

end


return Context


