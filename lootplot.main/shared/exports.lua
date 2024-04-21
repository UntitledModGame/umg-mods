
--[[
    lootplot.main does not do any global exports;
        but rather, exports a `main` table to the existing `lp` namespace.
]]

-- selene: allow(incorrect_standard_library_use)
lp.main = {}
local main = lp.main



do
local currentContext = nil

local lpWorldGroup = umg.group("lootplotContext")
lpWorldGroup:onAdded(function(ent)
    if not currentContext then
        currentContext = ent.lootplotContext
    else
        -- TODO: change this to a log, as opposed to a print
        print("WARNING::: Duplicate lootplot.main context created!!")
    end
end)

function main.isReady()
    return currentContext
end

function main.getContext()
    assert(main.isReady(), "Not ready yet! (Check using lp.main.isReady() )")
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
    STARTING_ROUND = 0,
    STARTING_LEVEL = 0,

    ROUNDS_PER_LEVEL = 4
},{__index=function(msg,k,v) error("undefined const: " .. tostring(k)) end})

