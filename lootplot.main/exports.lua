
--[[
    lootplot.main does not do any global exports;
        but rather, exports a `main` table to the existing `lp` namespace.
]]

-- selene: allow(incorrect_standard_library_use)
lp.main = {}


lp.main.constants = {
    --[[
        feel free to override any of these.
        Access via `lootplot.main.constants`
    ]] 
    STARTING_MONEY = 10,
    STARTING_POINTS = 0,
    STARTING_LEVEL = 0,

    ROUNDS_PER_LEVEL = 4
}

