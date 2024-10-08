local fonts = require("client.fonts")
local globalScale = require("client.globalScale")

local lg=love.graphics

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")



---@class lootplot.main.NewRunDialog: Element
local NewRunDialog = ui.Element("lootplot.main:NewRunDialog")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))

local function getTextScale()
    return globalScale.get() * 0.75
end

---@param newRunAction fun(seed:string|nil)
---@param cancelRunAction function?
function NewRunDialog:init(newRunAction, cancelRunAction)
    local e = {}
    e.base = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = BACKGROUND_COLOR
    })
    e.title = ui.elements.Text({
        text = "New Run",
        color = objects.Color.WHITE,
        outline=2,
        outlineColor = objects.Color.BLACK,
        font = fonts.getLargeFont(FONT_SIZE),
    })
    e.startButton = StretchableButton({
        onClick = function()
            local seed = e.seedInput:getText()
            local realSeed = nil
            if #seed > 0 then
                realSeed = seed
            end
            return newRunAction(realSeed)
        end,
        text = "Start New Run",
        color = objects.Color(1,1,1,1):setHSL(184, 0.7, 0.5),
        font = fonts.getLargeFont(FONT_SIZE),
    })
    assert(objects.Color.TRANSPARENT)
    if cancelRunAction then
        e.cancelButton = ui.elements.Button({
            click = cancelRunAction,
            image = "red_square_1",
            backgroundColor = objects.Color.TRANSPARENT,
            outlineColor = objects.Color.TRANSPARENT
        })
    end
    e.seedLabel = ui.elements.Text({
        text = "Seed: ",
        outline = 2,
        outlineColor = objects.Color.BLACK,
        color = objects.Color.WHITE,
        font = fonts.getSmallFont(FONT_SIZE),
        align = "left",
        getScale = getTextScale,
    })
    e.seedTooltip = ui.elements.Text({
        text = "[Leave empty for random seed]",
        align = "left",
        outline = 2,
        outlineColor = objects.Color.BLACK,
        color = objects.Color(1, 1, 1, 0.4),
        font = fonts.getSmallFont(FONT_SIZE),
        getScale = getTextScale,
    })
    e.seedInput = ui.elements.Input({
        textColor = objects.Color.WHITE,
        font = fonts.getSmallFont(FONT_SIZE),
        align = "left",
        maxLength = 20,
        backgroundColor = objects.Color(1, 1, 1, 0),
        getScale = getTextScale,
    })
    e.modsUsed = ui.elements.Text({
        text = "Mods used:\n[A, B, C, D]",
        outline = 2,
        outlineColor = objects.Color.BLACK,
        color = objects.Color.WHITE,
        font = fonts.getSmallFont(FONT_SIZE),
        align = "left",
        getScale = getTextScale,
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
    self.inputHeight = fonts.getSmallFont(FONT_SIZE):getHeight()
end

function NewRunDialog:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.05, 0.3)

    local title, body, buttonRegion, _ = r:splitVertical(0.2, 0.8, 0.3)
    local cancelButton
    if self.elements.cancelButton then
        local iw, ih = select(3, client.assets.images.red_square_1:getViewport())
        local s = globalScale.get() * 2
        local regW, regH = iw * s, ih * s
        local pad = 5
        cancelButton = layout.Region(0, 0, regW, regH)
            :attachToRightOf(r)
            :attachToTopOf(r)
            :moveUnit(-regW - pad, regH + pad)
    end
    body = body:padRatio(0.2)
    title = title:padRatio(0.33, 0.1, 0.33, 0.1)
        :moveRatio(0, 0.5 + math.sin(love.timer.getTime())/6)
    local seedBody, modsBody = body:splitVertical(1, 1)
    seedBody = seedBody:padRatio(0, 0.3, 0, 0.3)
    seedBody.h = self.inputHeight
    local seedLabel, seedInput = seedBody:splitHorizontal(1, 4)
    local startButton = buttonRegion:shrinkToAspectRatio(3,1):padRatio(0.1,0.25)

    self.elements.base:render(r:get())
    self.elements.title:render(title:get())
    self.elements.seedLabel:render(seedLabel:get())
    if #self.elements.seedInput:getText() == 0 then
        self.elements.seedTooltip:render(seedInput:get())
    end
    self.elements.seedInput:render(seedInput:get())
    self.elements.modsUsed:render(modsBody:get())

    self.elements.startButton:render(startButton:get())
    if self.elements.cancelButton then
        self.elements.cancelButton:render(cancelButton:get())
    end
end

return NewRunDialog
