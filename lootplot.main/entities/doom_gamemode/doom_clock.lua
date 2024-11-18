
--[[


- Doom-clock (item)
Provides win/lose conditions

]]


local interp = localization.newInterpolator
local loc = localization.localize




local EARLY_LEVELS = {
    100,250, 650, 1500, 3500, 7500
}
local RAMP_UP = 12

---@param levelNumber integer
local function getRequiredPoints(levelNumber)
    --[[
    levelNumber starts at 1, goes up infinitely.
    ]]
    if EARLY_LEVELS[levelNumber] then
        return EARLY_LEVELS[levelNumber]
    end

    local extra = 0
    if levelNumber > RAMP_UP then
        local exp = (levelNumber-(RAMP_UP-3))^2
        extra = math.floor((5 ^ exp)/10000) * 10000
    end
    return extra + math.floor((2^(levelNumber+0.5))/10) * 1000
end


--[[
for lv=1, 16 do
    print("LEVEL POINTS:",lv,getRequiredPoints(lv))
end
]]


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



---@param value number
---@param nsig integer
---@return string
local function showNSignificant(value, nsig)
	local zeros = math.floor(math.log10(math.max(math.abs(value), 1)))
	local mulby = 10 ^ math.max(nsig - zeros, 0)
	return tostring(math.floor(value * mulby) / mulby)
end


local POINTS = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}Points: %{colorEffect}%{points}{/c}/%{requiredPoints}")
local function drawPoints(ent, x,y, rot, sx,sy)
    local points = assert(lp.getPoints(ent), "no points")
    local requiredPoints = lp.main.getRequiredPoints(ent)
    local colorEffect
    if points >= requiredPoints then
        colorEffect = "{c r=0.1 g=1 b=0.2}"
    elseif points < 0 then
        colorEffect = "{c r=1 g=0.2 b=0.1}"
    else
        colorEffect = "{c r=1 g=1 b=1}"
    end

    local needPoints = POINTS({
        points = showNSignificant(points, 3),
        requiredPoints = requiredPoints,
        colorEffect = colorEffect
    })

    local font = love.graphics.getFont()
    local limit = 0xffff
    text.printRichCentered(needPoints, font, x, y - 40, limit, "left", rot, sx,sy)
end


local GAME_OVER = interp("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}{c r=0.7 g=0.1 b=0}GAME OVER! (%{points}/%{requiredPoints})")
local function drawGameOver(ent, x,y,rot,sx,sy)
    local font = love.graphics.getFont()
    local limit = 0xffff
    local points = assert(lp.getPoints(ent), "no points")
    local requiredPoints = lp.main.getRequiredPoints(ent)
    local gameOver = GAME_OVER({
        points = showNSignificant(points, 3),
        requiredPoints = requiredPoints,
    })
    text.printRichCentered(gameOver, font, x, y - 40, limit, "left", rot, sx,sy)
end



local MONEY = interp("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline}{c r=1 g=0.843 b=0.1}$ %{money}")

umg.defineEntityType("lootplot.main:doom_clock", {
    image = "doom_clock",

    layer = "world",
    triggers = {"RESET"},

    baseMaxActivations = 100,

    onUpdateServer = function(ent)
        local level = lp.getLevel(ent)
        local currentRequiredPoints = lp.main.getRequiredPoints(ent)
        local neededRequiredPoints = getRequiredPoints(level)

        if currentRequiredPoints ~= neededRequiredPoints then
            lp.setAttribute("REQUIRED_POINTS", ent, neededRequiredPoints)
        end
    end,

    onUpdateClient = moveClockToClearPosition,

    onDraw = function(ent, x,y, rot, sx,sy)
        --[[
        generally, we shouldnt use `onDraw` for entities;
        But this is a very special case :)
        ]]
        local scale = 1.5
        local font = love.graphics.getFont()
        local limit = 0xffff
    
        local money = MONEY({
            money = math.floor(assert(lp.getMoney(ent)))
        })
        text.printRichCentered(money, font, x, y - 24, limit, "left", rot, sx*scale,sy*scale)

        local points = lp.getPoints(ent)
        local requiredPoints = lp.main.getRequiredPoints(ent)
        local round = lp.main.getRound(ent)
        local numRounds = lp.main.getNumberOfRounds(ent)
        if (numRounds < round) and (points < requiredPoints) then
            drawGameOver(ent, x,y, rot, sx*scale, sy*scale)
        else
            drawPoints(ent, x,y, rot, sx*scale, sy*scale)
        end
    end,

    onActivate = function(ent)
        local round = lp.main.getRound(ent)
        local numOfRounds = lp.main.getNumberOfRounds(ent)
        local requiredPoints = lp.main.getRequiredPoints(ent)
        local points = lp.getPoints(ent)

        local newRound = round + 1
        lp.main.setRound(ent, newRound)
        if (newRound > numOfRounds) and (points < requiredPoints) then
            lose()
        end
    end
})


