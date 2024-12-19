---@class lootplot.backgrounds
local bg = {}

assert(not lp.backgrounds, "\27]8;;https://youtu.be/dQw4w9WgXcQ\27\\Unexpected error!\27]8;;\27\\")
lp.backgrounds = bg


umg.defineEvent("lootplot.backgrounds:backgroundChanged")
-- Note: The reason we don't use `sync.proxyEventToClient` is that we want to set
-- the background **first** then firing the event bus in the client so that calls to
-- `lp.backgrounds.getBackground()` inside the `lootplot.backgrounds:backgroundChanged`
-- evbus return up-to-date values.
umg.definePacket("lootplot.backgrounds:backgroundChanged", {typelist = {"string"}})


local IBackground = nil
local IBGTc = nil

if client then
    IBackground = require("client.IBackground")
    IBGTc = typecheck.interface(IBackground)
end

---Availability: **Client**
bg.backgroundTypecheck = IBGTc
---Availability: **Client**
bg.IBackground = IBackground

---@type lootplot.backgrounds.BackgroundInfoData[]
local registry = {}
---@type table<string, lootplot.backgrounds.BackgroundInfoData>
local defined = {}

---@class lootplot.backgrounds.BackgroundInfo
---@field public name string
---@field public constructor (fun():lootplot.backgrounds.IBackground)? @note this is nil on server-side
---@field public description string?
---@field public icon string?

---@class lootplot.backgrounds.BackgroundInfoData: lootplot.backgrounds.BackgroundInfo
---@field public id string

local registerBGTc = typecheck.assert("string", "table")
local registerBGTableTc = {"name"}
if client then
    registerBGTableTc[#registerBGTableTc+1] = "constructor"
end

---@param name string
---@param def lootplot.backgrounds.BackgroundInfo
function bg.registerBackground(name, def)
    registerBGTc(name, def)
    typecheck.assertKeys(def, registerBGTableTc)
    assert(not defined[name], "background '"..name.."' is already registered")

    if server then
        def.constructor = nil
    end

    ---@cast def lootplot.backgrounds.BackgroundInfoData
    def.id = name
    registry[#registry + 1] = def
    defined[name] = def
end

function bg.getRegisteredBackgrounds()
    return table.shallowCopy(registry)
end

---@type string?
local currentBackgroundName = nil

---Availability: Client and Server
function bg.getBackground()
    return currentBackgroundName
end

if client then

assert(IBGTc)

---@type lootplot.backgrounds.IBackground?
local previousBackground = nil
---@type lootplot.backgrounds.IBackground?
local currentBackground = nil
local interpolationTime = 0
local swapTime = 0

---@param background string?
---@param interpTime number?
local function setBGImpl(background, interpTime)
    interpTime = interpTime or 0
    local backgroundObj = nil

    if background then
        local bginfo = defined[background]
        if not bginfo then
            umg.melt("unknown background '"..background.."'")
        end
        if not bginfo.constructor then
            umg.melt("missing background constructor '"..background.."'")
        end

        backgroundObj = bginfo.constructor()
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

client.on("lootplot.backgrounds:backgroundChanged", function(data)
    local bgdata = json.decode(data)
    setBGImpl(bgdata.background, bgdata.interpolation)
    umg.call("lootplot.backgrounds:backgroundChanged", bgdata.background, bgdata.interpolation)
end)


---Availability: Client and Server
---@param background string?
---@param interpTime number?
function bg.setBackground(background, interpTime)
    if currentBackgroundName ~= background then
        if background then
            assert(defined[background], "unknown background")
        end

        setBGImpl(background, interpTime)
        umg.call("lootplot.backgrounds:backgroundChanged", background, interpTime)
        currentBackgroundName = background
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

else -- if client

---Availability: Client and Server
---@param background string?
---@param interpTime number?
function bg.setBackground(background, interpTime)
    if currentBackgroundName ~= background then
        currentBackgroundName = background
        -- Broadcasts so client can change the background
        server.broadcast("lootplot.backgrounds:backgroundChanged", json.encode({
            background = background,
            interpolation = interpTime
        }))
        umg.call("lootplot.backgrounds:backgroundChanged", background, interpTime)
    end
end

end -- if client

return bg
