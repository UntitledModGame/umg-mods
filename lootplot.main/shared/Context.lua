
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
}

function Context:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent
    assert(ent.plot, "Needs a plot!")

    local constants = lp.main.constants
    self.combo = 0
    self.money = constants.STARTING_MONEY
    self.points = constants.STARTING_POINTS
end


function Context:sync()
    -- syncs everything:
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





function Context:canGoNextRound()
    local ent = self.ownerEnt
    local plot = ent.plot
    -- we can only progress to the next round if the pipeline is empty.
    return not plot:isPipelineRunning()
end


umg.definePacket("lootplot.main:nextRound", {
    typelist = {}
})

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

else -- this is client-side

function Context:goNextRound()
    client.send("lootplot.main:nextRound")
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


function Context:getCurrentRound()
    return self.round
end





return Context


