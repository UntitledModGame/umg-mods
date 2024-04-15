
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

    self.money = constants.STARTING_MONEY
    self.points = constants.STARTING_POINTS
    self.round = constants.STARTING_ROUND
    self.level = constants.STARTING_LEVEL
    self.requiredPoints = 0
end


function Context:sync()
    -- syncs everything:
    for field, _ in pairs(VALUES) do
        self:syncValue(field)
    end
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
        ent.context[field] = val
    end)
end









--[[

roundService.

Handles progression between rounds, 
and *kinda* acts like a game-state-y object.

]]


local ws = require("shared.worldService")



umg.definePacket("lootplot.main:nextRound", {
    typelist = {}
})

if server then

local function resetFields(self)
    -- reset points:
    self.round = 0
    self.points = 0
    -- TODO: Some visual-update should be done here, 
    -- to the loot-monster maybe?
    self.level = self.level + 1
    self.requiredPoints = 0
    self:syncAll()
end


local function lose()
    -- todo; prolly need to send some message to client-side,
    -- and make the client open up some widget or something displaying:
    -- "YOU LOST".
end


local function nextRound()
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

    if ws.get("points") > ws.get("requiredPoints") then
        -- win condition!!
        nextLevel(self)
    end
    if self.round >= lp.main.constants.ROUNDS_PER_LEVEL then
        -- lose!
        lose(self)
    end
end

-- Just trust the client :shrug:
server.on("lootplot.main:nextRound", nextRound)

else

function requestNextRound()
    client.send("lootplot.main:nextRound")
end

end















--[[

points are shared between all players.
money is also shared between all players.

]]
if server then
function lp.overrides.setPoints(ent, x)
    currentContext.points = x
    currentContext:syncValue("points")
end
function lp.overrides.setMoney(ent, x)
    currentContext.money = x
    currentContext:syncValue("money")
end
end

function lp.overrides.getPoints(ent)
    return currentContext.points
end
function lp.overrides.getMoney(ent)
    return currentContext.money
end









return Context


