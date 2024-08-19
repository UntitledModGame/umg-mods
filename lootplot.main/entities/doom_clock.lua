
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


local function lose()
    lp.main.endGame(nil, false)
end

local function syncEntity(ent)
    sync.syncComponent(ent, "round")
    sync.syncComponent(ent, "level")
    sync.syncComponent(ent, "requiredPoints")
    sync.syncComponent(ent, "numberOfRounds")
end


local NUM_ROUNDS = 1

local function nextLevel(ent)
    -- reset points:
    ent.round = 1
    ent.level = ent.level + 1
    ent.requiredPoints = getRequiredPoints(ent.level)
    ent.numberOfRounds = NUM_ROUNDS
    lp.setPoints(ent, 0)
    syncEntity(ent)
end


umg.defineEntityType("lootplot.main:doom_clock", {
    image = "doom_clock",

    layer = "world",
    triggers = {"RESET"},

    baseMaxActivations = 100,

    onDraw = function(ent, x,y, rot, sx,sy, kx,ky)
        --[[
        generally, we shouldnt use `onDraw` for entities;
        But this is a very special case :)
        ]]
        local roundCount = loc("Round %{round}/%{numberOfRounds}", ent)

        local needPoints = loc("Points: %{points}/%{requiredPoints}", {
            points = math.min(lp.getPoints(ent), ent.requiredPoints),
            requiredPoints = ent.requiredPoints
        })
        local font = love.graphics.getFont()
        local limit = 0xffff
        text.printRichCentered(roundCount, font, x, y + 16, limit, "left", rot, sx,sy, kx,ky)
        text.printRichCentered(needPoints, font, x, y - 18, limit, "left", rot, sx,sy, kx,ky)
    end,

    init = function(ent)
        ent.round = lp.main.constants.STARTING_ROUND
        ent.level = lp.main.constants.STARTING_LEVEL
        ent.requiredPoints = getRequiredPoints(ent.level)
        ent.numberOfRounds = NUM_ROUNDS
    end,

    onActivate = function(ent)
        ent.round = ent.round + 1
        local points = lp.getPoints(ent)
        if points >= ent.requiredPoints then
            -- win condition!!
            lp.main.endGame(nil, true)
            nextLevel(ent)
        elseif ent.round > ent.numberOfRounds then
            -- lose!
            lose()
        end
        syncEntity(ent)
    end
})

end


