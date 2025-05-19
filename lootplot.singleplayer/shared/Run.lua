
--[[

Run:

There is one "Run" object when a lootplot.singleplayer game is running.
(The "Run" object belongs to the worldEnt)

----------------------------------

points are shared between all players.
money is also shared between all players.


]]

local settingManager = require("shared.setting_manager")

---@class lootplot.singleplayer.Run: objects.Class
local Run = objects.Class("lootplot.singleplayer:Run")


umg.definePacket("lootplot.singleplayer:syncContextAttribute", {
    typelist = {"entity", "string", "number"}
})

local attributeList = nil


umg.defineEntityType("lootplot.singleplayer:world", {})


---@param starterItem string
---@param difficulty string
---@param bg string
function Run:init(starterItem, difficulty, bg)
    assert(typecheck.isType(starterItem, "string"))

    local ent = server.entities.world()
    ent.lootplotMainRun = self
    ent.x = 0
    ent.y = 0
    self.ownerEnt = ent

    self.runHasEnded = false

    ent.plot = lp.Plot(
        ent,
        lp.singleplayer.constants.WORLD_PLOT_SIZE[1],
        lp.singleplayer.constants.WORLD_PLOT_SIZE[2]
    )

    -- we gotta store it here, since if the starter-item gets deleted,
    -- we still wanna know what one was used!
    self.starterItem = starterItem

    self.winAchievement = nil
    local etype = (client or server).entities[starterItem]
    if etype and etype.winAchievement then
        umg.log.info("DEFINING WIN ACHIEVEMENT IN RUN: ", etype.winAchievement)
        self.winAchievement = etype.winAchievement
    else
        umg.log.info("Unable to define win-achievement: ", etype)
    end

    self.currentBackground = bg

    self.difficulty = difficulty

    self.attrs = {}

    for _, a in ipairs(lp.getAllAttributes()) do
        self.attrs[a] = lp.getAttributeDefault(a)
    end

    local dInfo = lp.getDifficultyInfo(difficulty)
    if dInfo.difficulty <= 0 then
        -- on easy difficulties, ie <= 0, we only have 2 less levels
        self.attrs["NUMBER_OF_LEVELS"] = assert(self.attrs["NUMBER_OF_LEVELS"]) - 2
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
        local team = lp.singleplayer.PLAYER_TEAM

        if slotEnt.lootplotTeam == team then
            local ppos = lp.getPos(slotEnt)
            if ppos then
                local plot = ppos:getPlot()

                -- Reveal in KING-1 shape
                for y = -1, 1 do
                    for x = -1, 1 do
                        local newPPos = ppos:move(x, y)
                        if newPPos then
                            if not plot:isFogRevealed(newPPos, team) then
                                plot:setFogRevealed(newPPos, slotEnt.lootplotTeam, true)
                            end
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
    if not lp.getAttributeDefault(key) then
        error("Invalid attribute: " .. key)
    end
    server.broadcast("lootplot.singleplayer:syncContextAttribute", assert(self.ownerEnt), key, self.attrs[key])
end

end -- if server


---@return lootplot.Plot
function Run:getPlot()
    return self.ownerEnt.plot
end


if client then
    client.on("lootplot.singleplayer:syncContextAttribute", function(ent, field, val)
        assert(ent, "?")
        ent.lootplotMainRun.attrs[field] = val
    end)
end


function Run:getSingleplayerArgs()
    return {
        starterItem = self.starterItem,
        difficulty = self.difficulty,
        winAchievement = self.winAchievement
    }
end


function Run:getAttributeSetters()
    local attributeSetters = {}
    for _, attr in ipairs(lp.getAllAttributes()) do
        --[[
        in lootplot.singleplayer,
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
---@return lootplot.singleplayer.Run
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
    ---@class lootplot.singleplayer.RunMeta
    local t = {
        level = self.attrs.LEVEL,
        starterItem = self.starterItem,
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
    local run = lp.singleplayer.getRun()
    if run then
        run.currentBackground = bg
    end
end)

return Run


