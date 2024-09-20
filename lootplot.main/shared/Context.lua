
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


umg.definePacket("lootplot.main:syncContextAttribute", {
    typelist = {"entity", "string", "number"}
})

local attributeList = nil

function Context:init(ent)
    assert(umg.exists(ent), "Must pass an entity!")
    self.ownerEnt = ent
    assert(ent.plot, "Needs a plot!")

    local constants = lp.main.constants

    self.attrs = {}
    self.attrs.COMBO = 0
    self.attrs.LEVEL = 1
    self.attrs.MONEY = constants.STARTING_MONEY
    self.attrs.POINTS = constants.STARTING_POINTS

    self.attrs.REQUIRED_POINTS = constants.STARTING_POINTS
    self.attrs.ROUND = 1
    self.attrs.NUMBER_OF_ROUNDS = constants.ROUNDS_PER_LEVEL
    for _, a in ipairs(lp.getAllAttributes()) do
        assert(self.attrs[a], "we missed one!")
    end

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
    attributeList = attributeList or lp.getAllAttributes()
    for _, attr in ipairs(attributeList) do
        self:syncValue(attr)
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
    if not lp.isValidAttribute(key) then
        error("Invalid key: " .. key)
    end
    server.broadcast("lootplot.main:syncContextAttribute", self.ownerEnt, key, self.attrs[key])
end

if client then
    client.on("lootplot.main:syncContextAttribute", function(ent, field, val)
        ent.lootplotContext.attrs[field] = val
    end)
end


function Context:getAttributeSetters()
    local attributeSetters = {}
    for _, attr in ipairs(lp.getAllAttributes()) do
        --[[
        in lootplot.main,
        attributes are shared between ALL players.
        ]]
        attributeSetters[attr] = {
            set = function(ent, x)
                self.attrs[attr] = x
            end,
            get = function(ent)
                return self.attrs[attr]
            end
        }
    end
    return attributeSetters
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


