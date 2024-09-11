
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


local NUM_ROUNDS = 4

local function nextLevel(ent)
    -- reset points:
    ent.round = 1
    ent.level = ent.level + 1
    ent.requiredPoints = getRequiredPoints(ent.level)
    ent.numberOfRounds = NUM_ROUNDS
    lp.setPoints(ent, 0)
    lp.setLevel(ent, ent.level)
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
        local points = lp.getPoints(ent)
        local colorEffect
        if points > ent.requiredPoints then
            colorEffect = "{c r=0.1 g=1 b=0.2}"
        else
            colorEffect = "{c r=1 g=0.8 b=0.7}"
        end

        local needPoints = loc("{wavy freq=0.5 spacing=0.4 amp=0.5}{outline}Points: %{colorEffect}%{points}{/c}/%{requiredPoints}", {
            points = points,
            requiredPoints = ent.requiredPoints,
            colorEffect = colorEffect
        })

        local money = loc("{wavy freq=0.6 spacing=0.8 amp=0.4}{outline}{c r=0.4 g=1 b=0.5}$ %{money}", {
            money = math.floor(lp.getMoney(ent))
        })

        local font = love.graphics.getFont()
        local limit = 0xffff
        local scale = 1.5

        text.printRichCentered(needPoints, font, x, y - 40, limit, "left", rot, sx*scale,sy*scale, kx,ky)
        text.printRichCentered(money, font, x, y - 24, limit, "left", rot, sx*scale,sy*scale, kx,ky)
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
            nextLevel(ent)
        elseif ent.round > ent.numberOfRounds then
            -- lose!
            lose()
        end
        syncEntity(ent)
    end
})

if client then

--[[
    This code tries to relocate the doom clock if ther are slot or item below it.
    TODO: this is hacky, Maybe change this in the future
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

umg.on("@update", function()
    if not lp.main.isReady() then return end

    local context = lp.main.getContext()
    local dclock = context:getDoomClock()

    if dclock and umg.exists(dclock) then
        local plot = context:getPlot()

        for _, relpos in ipairs(ORDER_SEARCH.relativeCoords) do
            local px = dclock._plotX + relpos[1]
            local py = dclock._plotY + relpos[2]

            if px >= 0 and py >= 0 then
                local ppos = plot:getPPos(px, py)

                if not (lp.posToItem(ppos) or lp.posToSlot(ppos)) then
                    -- Move it here
                    local v = ppos:getWorldPos()
                    dclock.x = v.x
                    dclock.y = v.y
                    dclock.dimension = v.dimension
                    return
                end
            end
        end
    end
end)

end

end


