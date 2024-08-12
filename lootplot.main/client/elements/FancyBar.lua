
local lg=love.graphics

---@class lootplot.main.FancyBar: Element
local FancyBar = ui.Element("lootplot.main:FancyBar")

local CATCHUP_BAR_DURATION = 0.15

function FancyBar:init(args)
    ---@type fun():(number,number)
    self.getProgress = args.getProgress
    self.mainColor = {
        hue = args.mainColor.hue,
        saturation = args.mainColor.saturation,
    }
    self.catchUpColor = {
        hue = args.catchUpColor.hue,
        saturation = args.catchUpColor.saturation,
    }
    self.catchUpSpeed = args.catchUpSpeed or 5
    self.barOpacity = args.barOpacity or 1
    self.outlineWidth = args.outlineWidth or 0

    self.catchUpValue = 0
    self.previousValue = 0
    self.timeToCatch = CATCHUP_BAR_DURATION
end

local function HSLToRGBWithAlpha(h, s, l, a)
    local r, g, b = objects.Color.HSLtoRGB(h, s, l)
    return r, g, b, a
end

---@param hue number in degrees
---@param saturation number in [0..1]
---@param alpha number
---@param x number
---@param y number
---@param w number
---@param h number
function FancyBar.drawFancyBar(hue, saturation, alpha, x, y, w, h)
    local region = ui.Region(x, y, w, h)
    local mid1, mid2, bottom = region:splitVertical(4, 3, 1)
    local _,highlight,_ = mid1:splitVertical(1,1,2)

    love.graphics.setColor(HSLToRGBWithAlpha(hue, saturation, 0.7, alpha))
    love.graphics.rectangle("fill", mid1:get())
    love.graphics.setColor(HSLToRGBWithAlpha(hue, saturation, 0.5, alpha))
    love.graphics.rectangle("fill", mid2:get())
    love.graphics.setColor(HSLToRGBWithAlpha(hue, saturation, 0.3, alpha))
    love.graphics.rectangle("fill", bottom:get())
    love.graphics.setColor(HSLToRGBWithAlpha(hue, saturation, 0.85, alpha))
    love.graphics.rectangle("fill", highlight:padRatio(0.08,0,0.08,0):get())
end

function FancyBar:_updateCatchup(value)
    local valueDiffer = self.previousValue ~= value
    self.previousValue = value

    if value >= self.catchUpValue then
        -- Zero out the timeout
        self.catchUpValue = value
        self.timeToCatch = 0
        return false
    else
        if valueDiffer then
            self.timeToCatch = CATCHUP_BAR_DURATION
        else
            local dt = love.timer.getDelta()

            if self.timeToCatch > 0 then
                -- Subtract the timeToCatch
                -- TODO: The UI should have callback to update logic separately that passes dt
                self.timeToCatch = self.timeToCatch - dt
            else
                -- Subtract the catchupValue
                self.catchUpValue = math.max(self.catchUpValue - dt * self.catchUpSpeed, value)
            end
        end

        return true
    end
end

function FancyBar:onRender(x,y,w,h)
    -- Update catchup value
    local value, maxValue = self.getProgress()
    local totalRegion = ui.Region(x, y, w, h)
    local pad = w * self.outlineWidth
    local barRegion
    if pad > 0 then
        barRegion = totalRegion:padPixels(pad)
    else
        barRegion = totalRegion
    end

    -- NaN protection
    if maxValue == 0 then
        maxValue = 1
    end

    -- Draw black bar
    -- TODO: Make this optional?
    lg.setColor(0,0,0,1)
    lg.rectangle("fill", totalRegion:get())

    -- Draw the bar
    local actualBarRegion, catchupRegion
    if self:_updateCatchup(math.max(value, 0)) then
        actualBarRegion, catchupRegion = barRegion:splitHorizontal(
            value,
            self.catchUpValue - value,
            maxValue - self.catchUpValue
        )
        FancyBar.drawFancyBar(
            self.catchUpColor.hue,
            self.catchUpColor.saturation,
            self.barOpacity,
            catchupRegion:get()
        )
    else
        actualBarRegion = barRegion:splitHorizontal(value, maxValue - value)
    end

    FancyBar.drawFancyBar(
        self.mainColor.hue,
        self.mainColor.saturation,
        self.barOpacity,
        actualBarRegion:get()
    )
    lg.setColor(1,1,1,1)
end

return FancyBar
