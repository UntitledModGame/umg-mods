
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
    level=true, round=true,
    maxRound=true,
    state=true
}
local DURING_ROUND = 1
local BETWEEN_ROUND = 0

function Context:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent
    assert(ent.plot, "Needs a plot!")

    local constants = lp.main.constants
    self.money = constants.STARTING_MONEY
    self.points = constants.STARTING_POINTS
    self.round = constants.STARTING_ROUND
    self.level = constants.STARTING_LEVEL
    self.requiredPoints = lp.main.getRequiredPoints(self.level)
    self.maxRound = lp.main.getMaxRound(self.level)
    self.state = BETWEEN_ROUND
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

function Context:isDuringRound()
    return self.state == DURING_ROUND
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

function Context:nextLevel()
    -- reset points:
    self.round = 1
    self.points = 0
    -- TODO: Some visual-update should be done here, 
    -- to the loot-monster maybe?
    self.level = self.level + 1
    self.requiredPoints = lp.main.getRequiredPoints(self.level)
    self.maxRound = lp.main.getMaxRound(self.level)
    self:sync()
end


function Context:lose()
    -- todo; prolly need to send some message to client-side,
    -- and make the client open up some widget or something displaying:
    -- "YOU LOST".
    umg.melt("lost game!")
end


local function resetPlot(plot)
    --[[
    TODO: should this be a method on the plot?
    ]]
    plot:foreachItem(function(ent, _ppos)
        lp.reset(ent)
    end)
    plot:foreachSlot(function(ent, _ppos)
        lp.reset(ent)
    end)
    plot:trigger("RESET")
end


---@param self lootplot.Context
function Context:nextRound()
    if self:isDuringRound() then
        -- Nope.
        return
    end

    -- Progresses to next round.
    umg.call("lootplot.main:startRound")
    self.state = DURING_ROUND
    self:syncValue("state")

    local plot = self:getPlot()
    resetPlot(plot)

    plot:queue(function()
        self.round = self.round + 1
        umg.call("lootplot.main:finishRound")
        self:getPlot():reset()
        self.state = BETWEEN_ROUND

        if self.points >= self.requiredPoints then
            -- win condition!!
            self:nextLevel()
        elseif self.round > self.maxRound then
            -- lose!
            self:lose()
        end
        self:sync()
        print("nextRound finish")
    end)

    -- pulse all slots:
    lp.Bufferer()
        :all(plot)
        :to("SLOT") -- ppos-->slot
        :delay(0.2)
        :execute(function(_ppos, slotEnt)
            lp.tryTriggerEntity("PULSE", slotEnt)
        end)
end

-- Just trust the client :shrug:
server.on("lootplot.main:nextRound", function()
    lp.main.getContext():nextRound()
end)

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

function Context:getCurrentRound()
    return self.round
end





return Context


