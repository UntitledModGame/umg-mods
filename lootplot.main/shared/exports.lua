
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
        umg.log.fatal("WARNING::: Duplicate lootplot.main context created!!")
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
