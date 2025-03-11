
--[[


- Doom-clock (item)
Provides win/lose conditions

]]



local EARLY_LEVELS = {
    60, 400, 1500, 4000, 10000, 35000
}


local function makePretty(num)
    --[[
    132 --> 130
    67043 --> 67000
    12 --> 12
    1349545442335 --> 13000000000
    etc
    ]]
    local numZeros = math.floor(math.log(num, 10))
    local floorVal = 10 ^ (numZeros)
    return math.floor(num / floorVal) * floorVal
end


---@param levelNumber integer
local function getRequiredPoints(levelNumber)
    --[[
    levelNumber starts at 1, goes up infinitely.
    ]]
    if EARLY_LEVELS[levelNumber] then
        return EARLY_LEVELS[levelNumber]
    end

    local GROWTH_PER_LEVEL = 2.5
    local number = (GROWTH_PER_LEVEL^(levelNumber)) * 100
    return makePretty(number)
end






--[[
for lv=1, 16 do
    print("LEVEL POINTS:",lv,getRequiredPoints(lv))
end
]]


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
                ent.x, ent.y, ent.dimension = ppos:getWorldPos()
                return
            end
        end
    end
end



umg.defineEntityType("lootplot.s0:doom_clock", {
    image = "doom_clock",

    layer = "world",

    baseMaxActivations = 100,

    onUpdateServer = function(ent)
        local level = lp.getLevel(ent)
        local currentRequiredPoints = lp.getRequiredPoints(ent)
        local neededRequiredPoints = getRequiredPoints(level)

        if currentRequiredPoints ~= neededRequiredPoints then
            lp.setAttribute("REQUIRED_POINTS", ent, neededRequiredPoints)
        end
    end,

    onUpdateClient = moveClockToClearPosition,
})


