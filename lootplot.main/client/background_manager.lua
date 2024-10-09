local backgroundManager = {}


---@type lootplot.main.Background?
local previousBackground = nil
---@type lootplot.main.Background?
local currentBackground = nil
local interpolationTime = 0
local swapTime = 0

---@param background lootplot.main.Background?
---@param interpTime number?
function backgroundManager.setBackground(background, interpTime)
    interpTime = interpTime or 0

    if interpTime > 0 then
        -- Perform interpolation
        previousBackground = currentBackground
        currentBackground = background

        -- Make it seamless
        local oldInterpolationValue = swapTime < interpolationTime and swapTime / interpolationTime or 0
        interpolationTime = interpTime
        swapTime = oldInterpolationValue * interpTime
    else
        -- Change directly
        previousBackground = nil
        currentBackground = background
        interpolationTime = 0
        swapTime = 0
    end
end

umg.on("@update", function(dt)
    swapTime = math.min(swapTime + dt, interpolationTime)

    if previousBackground then
        previousBackground:update(dt)
    end

    if currentBackground then
        currentBackground:update(dt)
    end
end)

umg.on("rendering:drawBackground", function()
    if interpolationTime > 0 then
        local interpolationValue = swapTime / interpolationTime

        if previousBackground then
            if interpolationValue >= 1 then
                previousBackground = nil
            else
                previousBackground:draw(1 - interpolationValue)
            end
        end

        if currentBackground then
            currentBackground:draw(interpolationValue)
        end
    elseif currentBackground then
        currentBackground:draw(1)
    end
end)

return backgroundManager
