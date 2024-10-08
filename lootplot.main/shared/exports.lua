
--[[
    lootplot.main does not do any global exports;
        but rather, exports a `main` table to the existing `lp` namespace.
]]

-- selene: allow(incorrect_standard_library_use)
assert(not lp.main, "invalid mod setup")
local main = {}


local currentRun = nil

local lpWorldGroup = umg.group("lootplotMainRun")
lpWorldGroup:onAdded(function(ent)
    --[[
    TODO: this whole code feels hacky and weirdddd
    ]]
    if not currentRun then
        currentRun = ent.lootplotMainRun
        lp.initialize(currentRun:getAttributeSetters())
    else
        umg.log.fatal("WARNING::: Duplicate lootplot.main context created!!")
    end
end)

---Availability: Client and Server
function main.isReady()
    return not not currentRun
end

---Availability: Client and Server
---@return lootplot.Run
function main.getRun()
    assert(currentRun, "Not ready yet! (Check using lp.main.isReady() )")
    return currentRun
end

---Availability: Client and Server
---@param ent Entity
---@return number
function main.getRound(ent)
    return lp.getAttribute("ROUND", ent)
end
---Availability: Client and Server
---@param ent Entity
function main.setRound(ent, x)
    lp.setAttribute("ROUND", ent, x)
end



---Availability: Client and Server
---@param ent Entity
---@return number
function main.getNumberOfRounds(ent)
    return lp.getAttribute("NUMBER_OF_ROUNDS", ent)
end

---Availability: Client and Server
---@param ent Entity
---@return number
function main.getRequiredPoints(ent)
    return lp.getAttribute("REQUIRED_POINTS", ent)
end



local winLose = require("shared.win_lose")

if server then
    ---Availability: **Server**
    ---@param clientId string|nil
    ---@param win boolean
    function main.endGame(clientId, win)
        return winLose.endGame(clientId, win)
    end
end

---Availability: Client and Server
main.constants = setmetatable({
    --[[
        feel free to override any of these.
        Access via `lootplot.main.constants`
    ]] 
    WORLD_PLOT_SIZE = 40,

    STARTING_MONEY = 10,
    STARTING_POINTS = 0,
    ROUNDS_PER_LEVEL = 4,
},{__index=function(msg,k,v) error("undefined const: " .. tostring(k)) end})

---Availability: Client and Server
lp.main = main
