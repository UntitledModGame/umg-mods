
--[[
    lootplot.main does not do any global exports;
        but rather, exports a `main` table to the existing `lp` namespace.
]]

-- selene: allow(incorrect_standard_library_use)
assert(not lp.main, "invalid mod setup")

---Availability: Client and Server
---@class lp.main.mod
local main = {}


local currentContext = nil

local lpWorldGroup = umg.group("lootplotContext")
lpWorldGroup:onAdded(function(ent)
    if not currentContext then
        currentContext = ent.lootplotContext
        lp.initialize(currentContext)
    else
        umg.log.fatal("WARNING::: Duplicate lootplot.main context created!!")
    end
end)

---Availability: Client and Server
function main.isReady()
    return not not currentContext
end

---Availability: Client and Server
---@return lootplot.Context
function main.getContext()
    assert(currentContext, "Not ready yet! (Check using lp.main.isReady() )")
    return currentContext
end

---Availability: Client and Server
function main.getRoundInfo()
    local ctx = main.getContext()
    local doomclock = ctx:getDoomClock()
    --[[
    todo: this is yucky, and tightly coupled to doomclock, in a WEIRD way.
    ]]
    return doomclock.round, doomclock.numberOfRounds
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
    STARTING_ROUND = 1,
    STARTING_LEVEL = 1,
},{__index=function(msg,k,v) error("undefined const: " .. tostring(k)) end})

lp.main = main
