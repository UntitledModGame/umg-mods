---@class lootplot.backgrounds
local bg = {}

assert(not lp.backgrounds, "\27]8;;https://youtu.be/dQw4w9WgXcQ\27\\Unexpected error!\27]8;;\27\\")
lp.backgrounds = bg

local IBackground = require("client.IBackground")
local IBGTc = typecheck.interface(IBackground)
bg.backgroundTypecheck = IBGTc
bg.IBackground = IBackground

---@type lootplot.backgrounds.BackgroundInfo[]
local registry = {}
---@type table<string, lootplot.backgrounds.BackgroundInfo>
local defined = {}

---@class lootplot.backgrounds.BackgroundInfo
---@field public name string
---@field public constructor fun():lootplot.backgrounds.IBackground
---@field public description string?
---@field public icon string?

local registerBGTc = typecheck.assert("string", "table")
local registerBGTableTc = {"name", "constructor"}

---@param name string
---@param def lootplot.backgrounds.BackgroundInfo
function bg.registerBackground(name, def)
    registerBGTc(name, def)
    typecheck.assertKeys(def, registerBGTableTc)
    assert(not defined[name], "background '"..name.."' is already registered")

    registry[#registry + 1] = def
    defined[name] = def
end

---@return lootplot.backgrounds.BackgroundInfo[]
function bg.getRegisteredBackgrounds()
    return table.copy(registry, false)
end


---@type lootplot.backgrounds.IBackground?
local previousBackground = nil
---@type lootplot.backgrounds.IBackground?
local currentBackground = nil
---@type string?
local currentBackgroundName = nil
local interpolationTime = 0
local swapTime = 0

---@param background string?
---@param interpTime number?
function bg.setBackground(background, interpTime)
    interpTime = interpTime or 0
    local backgroundObj = nil

    if background then
        backgroundObj = assert(defined[background], "unknown background").constructor()
        IBGTc(backgroundObj)
    end

    if interpTime > 0 then
        -- Perform interpolation
        previousBackground = currentBackground
        currentBackground = backgroundObj

        -- Make it seamless
        local oldInterpolationValue = swapTime < interpolationTime and swapTime / interpolationTime or 0
        interpolationTime = interpTime
        swapTime = oldInterpolationValue * interpTime
    else
        -- Change directly
        previousBackground = nil
        currentBackground = backgroundObj
        interpolationTime = 0
        swapTime = 0
    end

    currentBackgroundName = background
end

function bg.getBackground()
    return currentBackgroundName
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


return bg