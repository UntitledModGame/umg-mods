
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
    points=true,requiredPoints=true,
    level=true, round=true
}


function Context:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent
    assert(ent.plot, "Needs a plot!")

    local constants = lp.main.constants
    self.money = constants.STARTING_MONEY
    self.points = constants.STARTING_POINTS
    self.round = constants.STARTING_ROUND
    self.level = constants.STARTING_LEVEL
    self.requiredPoints = 100
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
    local pipeline = ent.plot.pipeline
    -- we can only progress to the next round if the pipeline is empty.
    return pipeline:isEmpty()
end


umg.definePacket("lootplot.main:nextRound", {
    typelist = {}
})

if server then

local function nextLevel(self)
    -- reset points:
    self.round = 0
    self.points = 0
    -- TODO: Some visual-update should be done here, 
    -- to the loot-monster maybe?
    self.level = self.level + 1
    self.requiredPoints = 0
end


local function lose(self)
    -- todo; prolly need to send some message to client-side,
    -- and make the client open up some widget or something displaying:
    -- "YOU LOST".
    umg.melt("lost game!")
end

---@param self lootplot.Context
local function nextRound(self)
    -- Progresses to next round.
    assert(server,"wot wot")

    umg.call("lootplot.main:startRound")

    -- pulse all slots:
    lp.Bufferer()
        :all(self:getPlot())
        :slots() -- ppos-->slot
        :delay(0.2)
        :execute(function(_ppos, slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)

    -- TODO: Give reward-money at end of round

    self.round = self.round + 1
    umg.call("lootplot.main:finishRound")
    self:getPlot():reset()

    if self.points >= self.requiredPoints then
        -- win condition!!
        nextLevel(self)
    elseif self.round >= lp.main.constants.ROUNDS_PER_LEVEL then
        -- lose!
        lose(self)
    end
    self:sync()
end

-- Just trust the client :shrug:
server.on("lootplot.main:nextRound", function()
    nextRound(lp.main.getContext())
end)

else

function Context:goNextRound()
    client.send("lootplot.main:nextRound")
end

end







--[[

points are shared between all players.
money is also shared between all players.

]]
if server then
function lp.overrides.setPoints(ent, x)
    local ctx = lp.main.getContext()
    ctx.points = x
    ctx:syncValue("points")
end
function lp.overrides.setMoney(ent, x)
    local ctx = lp.main.getContext()
    ctx.money = x
    ctx:syncValue("money")
end
end

function lp.overrides.getPoints(ent)
    local ctx = lp.main.getContext()
    return ctx.points
end
function lp.overrides.getMoney(ent)
    local ctx = lp.main.getContext()
    return ctx.money
end









return Context


