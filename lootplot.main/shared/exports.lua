
--[[
    lootplot.main does not do any global exports;
        but rather, exports a `main` table to the existing `lp` namespace.
]]

-- selene: allow(incorrect_standard_library_use)
assert(not lp.main, "invalid mod setup")
local main = {}



do
local currentContext = nil

local lpWorldGroup = umg.group("lootplotContext")
lpWorldGroup:onAdded(function(ent)
    if not currentContext then
        currentContext = ent.lootplotContext
        lp.initialize(currentContext)
    else
        -- TODO: change this to a log, as opposed to a print
        print("WARNING::: Duplicate lootplot.main context created!!")
    end
end)

function main.isReady()
    return not not currentContext
end

---@return lootplot.Context
function main.getContext()
    assert(currentContext, "Not ready yet! (Check using lp.main.isReady() )")
    return currentContext
end
end


local EARLY_LEVELS = {
    5,5, 10, 60, 400
}
---@param levelNumber integer
function main.getRequiredPoints(levelNumber)
    --[[
    levelNumber starts at 1, goes up infinitely.
    ]]
    if EARLY_LEVELS[levelNumber] then
        return EARLY_LEVELS[levelNumber]
    end
    --[[
    TODO: add a difficulty multiplier here?
    ]]

    -- todo: could make this exponential
    return math.floor(levelNumber^2.6 / 10) * 100
end

---@param levelNumber integer
function main.getMaxRound(levelNumber)
    return 4 -- chosen by fair dice roll.
             -- guaranteed to be random.
end

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
