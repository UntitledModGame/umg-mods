
--[[

Run:

There is one "Run" object when a lootplot.main game is running.
(The "Run" object belongs to the worldEnt)

----------------------------------

points are shared between all players.
money is also shared between all players.

Objective:
Get enough points to kill the loot-monster.


]]

---@class lootplot.main.Run: objects.Class
local Run = objects.Class("lootplot.main:Run")


umg.definePacket("lootplot.main:syncContextAttribute", {
    typelist = {"entity", "string", "number"}
})

local attributeList = nil


umg.defineEntityType("lootplot.main:world", {})


function Run:init()

    local ent = server.entities.world()
    ent.lootplotMainRun = self
    ent.x = 0
    ent.y = 0
    self.ownerEnt = ent

    ent.plot = lp.Plot(
        ent,
        lp.main.constants.WORLD_PLOT_SIZE,
        lp.main.constants.WORLD_PLOT_SIZE
    )

    local constants = lp.main.constants

    self.attrs = {}
    self.attrs.COMBO = 0
    self.attrs.LEVEL = 1
    self.attrs.MONEY = constants.STARTING_MONEY
    self.attrs.POINTS = constants.STARTING_POINTS

    self.attrs.REQUIRED_POINTS = 5 -- HACK: this is hardcoded.
    self.attrs.ROUND = 1
    self.attrs.NUMBER_OF_ROUNDS = constants.ROUNDS_PER_LEVEL
    for _, a in ipairs(lp.getAllAttributes()) do
        assert(self.attrs[a], "we missed one!")
    end
end




function Run:sync()
    -- syncs everything:
    assert(server,"?")
    attributeList = attributeList or lp.getAllAttributes()
    for _, attr in ipairs(attributeList) do
        self:syncValue(attr)
    end
end

function Run:tick()
    local plot = self:getPlot()
    plot:tick()
end

---@return lootplot.Plot
function Run:getPlot()
    return self.ownerEnt.plot
end


function Run:syncValue(key)
    assert(server, "This function can only be called on server-side.")
    if not lp.isValidAttribute(key) then
        error("Invalid key: " .. key)
    end
    server.broadcast("lootplot.main:syncContextAttribute", self.ownerEnt, key, self.attrs[key])
end

if client then
    client.on("lootplot.main:syncContextAttribute", function(ent, field, val)
        ent.lootplotMainRun.attrs[field] = val
    end)
end


function Run:getAttributeSetters()
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
function Run:setSpeedMultipler(mult)
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


return Run


