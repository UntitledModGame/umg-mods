local match3 = {}

---@param ppos lootplot.PPos
---@param n integer
---@return lootplot.PPos?
local function moveHorizontal(ppos, n)
    return ppos:move(n, 0)
end

---@param ppos lootplot.PPos
---@param n integer
---@return lootplot.PPos?
local function moveVertical(ppos, n)
    return ppos:move(0, n)
end

local movefunc = {
    [true] = moveVertical,
    [false] = moveHorizontal
}

---@param a lootplot.PPos
---@param b lootplot.PPos
local function sortBySlotIndex(a, b)
    return a:getSlotIndex() < b:getSlotIndex()
end

---@param ppos lootplot.PPos
---@param isMatch fun(ppos:lootplot.PPos):boolean
---@param vertical boolean
local function getLineOfPPoses(ppos, isMatch, vertical)
    ---@type lootplot.PPos[]
    local linePPoses = {}

    -- Test stop
    for stop = 0, 500 do
        local targPPos = movefunc[vertical](ppos, stop)
        if targPPos and isMatch(targPPos) then
            linePPoses[#linePPoses+1] = targPPos
        else
            break
        end
    end

    -- Test start
    for start = -1, -501, -1 do
        local targPPos = movefunc[vertical](ppos, start)
        if targPPos and isMatch(targPPos) then
            linePPoses[#linePPoses+1] = targPPos
        else
            break
        end
    end

    table.sort(linePPoses, sortBySlotIndex)
    return linePPoses
end

---@param ppos lootplot.PPos
---@param isMatch fun(ppos:lootplot.PPos):boolean
---@param result objects.Set
---@param seen objects.Set
---@param vertical boolean
local function test(ppos, isMatch, result, seen, vertical)
    -- Find all PPoses in horizontal or vertical line
    local lines = getLineOfPPoses(ppos, isMatch, vertical)

    if #lines >= 3 then
        -- Add to match3 result
        for _, p in ipairs(lines) do
            result:add(p:getSlotIndex())
        end
    end

    for _, p in ipairs(lines) do
        local si = p:getSlotIndex()
        if not seen:has(si) then
            seen:add(si)
            test(p, isMatch, result, seen, not vertical)
        end
    end
end

---@param ppos lootplot.PPos
---@param isMatch fun(ppos:lootplot.PPos):boolean
---@return lootplot.PPos[]
function match3.test(ppos, isMatch)
    local resultset = objects.Set()
    local seen = objects.Set()
    test(ppos, isMatch, resultset, seen, false)

    local result = {}
    local plot = ppos:getPlot()
    for _, si in ipairs(resultset) do
        result[#result+1] = plot:getPPosFromSlotIndex(si)
    end
    return result
end

return match3
