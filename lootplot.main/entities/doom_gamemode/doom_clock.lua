
--[[


- Doom-clock (item)
Provides win/lose conditions

]]


local interp = localization.newInterpolator




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


--[[
    This code tries to relocate the doom clock if ther are slot or item below it.
]]
-- Plots to be tested for heurestic search
local SEARCH_SIZE = 2 -- 1 = 3x3, 2 = 5x5, 3 = 7x7, and so on.
local ORDER_SEARCH = lp.targets.KingShape(SEARCH_SIZE)
table.insert(ORDER_SEARCH.relativeCoords, {0, 0}) -- Include center

table.sort(ORDER_SEARCH.relativeCoords, function (a, b)
    local d1 = math.sqrt(a[1] * a[1] + a[2] * a[2])
    local d2 = math.sqrt(b[1] * b[1] + b[2] * b[2])
    return d1 < d2
end)

local function moveClockToClearPosition(ent)
    local ppos = lp.getPos(ent)
    if not ppos then return end
    local plot = ppos:getPlot()

    for _, relpos in ipairs(ORDER_SEARCH.relativeCoords) do
        local px = ent._plotX + relpos[1]
        local py = ent._plotY + relpos[2]

        if px >= 0 and py >= 0 then
            local ppos = plot:getPPos(px, py)

            if not (lp.posToItem(ppos) or lp.posToSlot(ppos)) then
                -- Move it here
                local v = ppos:getWorldPos()
                ent.x = v.x
                ent.y = v.y
                ent.dimension = v.dimension
                return
            end
        end
    end
end



local POINTS = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}Points: %{colorEffect}%{points}{/c}/%{requiredPoints}")
local MONEY = interp("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline}{c r=1 g=0.843 b=0.1}$ %{money}")

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
        moveClockToClearPosition(ent)

        local points = lp.getPoints(ent)
        local requiredPoints = lp.main.getRequiredPoints(ent)
        local colorEffect
        if points > requiredPoints then
            colorEffect = "{c r=0.1 g=1 b=0.2}"
        elseif points < 0 then
            colorEffect = "{c r=1 g=0.2 b=0.1}"
        else
            colorEffect = "{c r=1 g=1 b=1}"
        end

        local needPoints = POINTS({
            points = points,
            requiredPoints = requiredPoints,
            colorEffect = colorEffect
        })

        local money = MONEY({
            money = math.floor(assert(lp.getMoney(ent)))
        })

        local font = love.graphics.getFont()
        local limit = 0xffff
        local scale = 1.5

        text.printRichCentered(needPoints, font, x, y - 40, limit, "left", rot, sx*scale,sy*scale)
        text.printRichCentered(money, font, x, y - 24, limit, "left", rot, sx*scale,sy*scale)
    end,

    onActivate = function(ent)
        local round = lp.main.getRound(ent)
        local numOfRounds = lp.main.getNumberOfRounds(ent)
        local requiredPoints = lp.main.getRequiredPoints(ent)
        local points = lp.getPoints(ent)

        local level = lp.getLevel(ent)
        lp.setAttribute("REQUIRED_POINTS", ent, getRequiredPoints(level))

        local newRound = round + 1
        lp.main.setRound(ent, newRound)
        if (newRound > numOfRounds) and (points < requiredPoints) then
            lose()
        end
    end
})


