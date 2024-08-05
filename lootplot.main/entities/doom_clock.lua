
--[[


- Doom-clock (item)
Provides win/lose conditions

]]


local loc = localization.localize


do


local EARLY_LEVELS = {
    5,5, 10, 60, 400
}
---@param levelNumber integer
local function getRequiredPoints(levelNumber)
    --[[
    levelNumber starts at 1, goes up infinitely.
    ]]
    if EARLY_LEVELS[levelNumber] then
        return EARLY_LEVELS[levelNumber]
    end
    -- TODO: add a difficulty multiplier here?

    -- todo: could make this exponential
    return math.floor(levelNumber^2.6 / 10) * 100
end



local function nextLevel(ent)
    -- reset points:
    ent.round = 1
    ent.level = ent.level + 1
    ent.requiredPoints = getRequiredPoints(ent.level)
    ent.numberOfRounds = 4
    sync(ent)
end


local function lose()
    --[[
    TODO: proper lose-screen here.
    ]]
    umg.melt("NYI")
end

local function sync(ent)
    return
end


lp.defineItem("lootplot.main:doom_clock", {
    name = loc("Doom clock"),
    triggers = {"RESET"},
    description = loc("This item serves as the Win/Lose condition."),
    rarity = lp.rarities.UNIQUE,

    init = function(ent)
        ent.round = constants.STARTING_ROUND
        ent.requiredPoints = lp.main.getRequiredPoints(ent.level)
        ent.level = constants.STARTING_LEVEL
        ent.numberOfRounds = 4
    end,

    onActivate = function(ent)
        ent.round = ent.round + 1
        if ent.points >= ent.requiredPoints then
            -- win condition!!
            nextLevel(ent)
        elseif ent.round > ent.maxRound then
            -- lose!
            lose()
        end
        sync(ent)
    end
})

end


