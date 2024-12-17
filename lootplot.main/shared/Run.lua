
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

local settingManager = require("shared.setting_manager")

---@class lootplot.main.Run: objects.Class
local Run = objects.Class("lootplot.main:Run")


umg.definePacket("lootplot.main:syncContextAttribute", {
    typelist = {"entity", "string", "number"}
})

local attributeList = nil


umg.defineEntityType("lootplot.main:world", {})


---@param perkItem string
---@param bg string
function Run:init(perkItem, bg)
    assert(typecheck.isType(perkItem, "string"))

    local ent = server.entities.world()
    ent.lootplotMainRun = self
    ent.x = 0
    ent.y = 0
    self.ownerEnt = ent

    ent.plot = lp.Plot(
        ent,
        lp.main.constants.WORLD_PLOT_SIZE[1],
        lp.main.constants.WORLD_PLOT_SIZE[2]
    )

    local constants = lp.main.constants

    self.perkItem = perkItem
    self.currentBackground = bg

    self.attrs = {}
    self.attrs.COMBO = 0
    self.attrs.LEVEL = 1
    self.attrs.MONEY = constants.STARTING_MONEY
    self.attrs.POINTS = constants.STARTING_POINTS

    self.attrs.REQUIRED_POINTS = 0
    self.attrs.ROUND = 1
    self.attrs.NUMBER_OF_ROUNDS = constants.ROUNDS_PER_LEVEL
    self.attrs.POINTS_MUL = 1
    for _, a in ipairs(lp.getAllAttributes()) do
        assert(self.attrs[a], "we missed one!")
    end
end




if server then

function Run:sync()
    -- syncs everything:
    attributeList = attributeList or lp.getAllAttributes()
    for _, attr in ipairs(attributeList) do
        self:syncValue(attr)
    end
end

local slotGroup = umg.group("slot")

---@param dt number
function Run:tick(dt)
    -- Reveal fog
    for _, slotEnt in ipairs(slotGroup) do
        if slotEnt.lootplotTeam then
            local ppos = lp.getPos(slotEnt)
            if ppos then
                local plot = ppos:getPlot()

                -- Reveal in KING-1 shape
                for y = -1, 1 do
                    for x = -1, 1 do
                        local newPPos = ppos:move(x, y)
                        if newPPos then
                            plot:setFogRevealed(newPPos, slotEnt.lootplotTeam, true)
                        end
                    end
                end
            end
        end
    end

    -- Update plot
    local plot = self:getPlot()
    plot:tick(dt)
end


function Run:syncValue(key)
    if not lp.isValidAttribute(key) then
        error("Invalid key: " .. key)
    end
    server.broadcast("lootplot.main:syncContextAttribute", assert(self.ownerEnt), key, self.attrs[key])
end

end -- if server


---@return lootplot.Plot
function Run:getPlot()
    return self.ownerEnt.plot
end


if client then
    client.on("lootplot.main:syncContextAttribute", function(ent, field, val)
        assert(ent, "?")
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

---@param attr string
---@return number
function Run:getAttribute(attr)
    return assert(self.attrs[attr])
end




if server then

function Run:canSerialize()
    return not self:getPlot():isPipelineRunning()
end

function Run:serialize()
    assert(self:canSerialize(), "cannot serialize run while pipeline is running")
    self:getPlot():removeDeletedEntities()
    return umg.serialize(self)
end

---@param data string
---@return lootplot.main.Run
function Run.deserialize(data)
    return assert(umg.deserialize(data, {
        entityTypeFallbackHandler = function(name)
            umg.log.error("Entity type not found: "..name)

            if name:sub(-5) == "_slot" then
                return server.entities[lp.FALLBACK_NULL_SLOT]
            else
                return server.entities[lp.FALLBACK_NULL_ITEM]
            end
        end
    }))
end



function Run:getMetadata()
    ---@class lootplot.main.RunMeta
    local t = {
        level = self.attrs.LEVEL,
        perk = self.perkItem,
        round = self.attrs.ROUND,
        maxRound = self.attrs.NUMBER_OF_ROUNDS,
        points = self.attrs.POINTS,
        requiredPoints = self.attrs.REQUIRED_POINTS
    }
    return t
end



-- Pipeline multipler
umg.answer("lootplot:getPipelineDelayMultiplier", function()
    return 1 / 2 ^ settingManager.getSpeedFactor()
end)

end -- if server

function Run:isLose()
    return self.attrs.ROUND > self.attrs.NUMBER_OF_ROUNDS and self.attrs.POINTS < self.attrs.REQUIRED_POINTS
end



function Run:getBackground()
    return self.currentBackground
end

umg.on("lootplot.backgrounds:backgroundChanged", function(bg)
    local run = lp.main.getRun()
    if run then
        run.currentBackground = bg
    end
end)

return Run


