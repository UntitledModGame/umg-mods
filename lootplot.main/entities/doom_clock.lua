
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
    lp.setPoints(ent, 0)
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
    image = "doom_clock",
    triggers = {"RESET"},
    description = loc("This item serves as the Win/Lose condition."),
    rarity = lp.rarities.UNIQUE,

    onDraw = function(ent, x,y, rot, sx,sy, kx,ky)
        --[[
        generally, we shouldnt use `onDraw` for entities;
        But this is a very special case :)
        ]]
        local roundCount = loc("Round %{round}/%{numberOfRounds}", ent)

        local needPoints = loc("Need %{required} points", {
            required = math.max(0, ent.requiredPoints - lp.getPoints(ent))
        })
        local font = love.graphics.getFont()
        local limit = 0xffff
        text.printRichText(roundCount, font, x,y, limit, rot, sx,sy, kx,ky)
        text.printRichText(needPoints, font, x,y, limit, rot, sx,sy, kx,ky)
    end,

    init = function(ent)
        ent.round = lp.main.constants.STARTING_ROUND
        ent.level = lp.main.constants.STARTING_LEVEL
        ent.requiredPoints = getRequiredPoints(ent.level)
        ent.numberOfRounds = 4
    end,

    onActivate = function(ent)
        ent.round = ent.round + 1
        local points = lp.getPoints(ent)
        if points >= ent.requiredPoints then
            -- win condition!!
            nextLevel(ent)
        elseif ent.round > ent.numberOfRounds then
            -- lose!
            lose()
        end
        sync(ent)
    end
})

end


