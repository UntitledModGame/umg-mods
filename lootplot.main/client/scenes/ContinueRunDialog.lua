local fonts = require("client.fonts")
local globalScale = require("client.globalScale")

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")



---@class lootplot.main.ContinueRunDialog: Element
local ContinueRunDialog = ui.Element("lootplot.main:ContinueRunDialog")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))

---@param continueRunAction function
---@param newRunAction fun(seed:string|nil)
function ContinueRunDialog:init(continueRunAction, newRunAction)
    local e = {}
    e.base = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = BACKGROUND_COLOR,
        scale = 2
    })
    e.title = ui.elements.Text({
        text = "Continue Run?",
        color = objects.Color.WHITE,
        outline = 2,
        outlineColor = objects.Color.BLACK,
        font = fonts.getLargeFont(FONT_SIZE),
    })
    e.newRunButton = StretchableButton({
        onClick = function()
            return newRunAction(nil)
        end,
        text = "Start New Run",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })
    e.continueRunButton = StretchableButton({
        onClick = continueRunAction,
        text = "Continue Run",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(184, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })
    e.newRunInfo = ui.elements.Text({
        text = "Starting new\nrun will\noverwrite your\nexisting run.",
        color = objects.Color.WHITE,
        outline = 1,
        outlineColor = objects.Color.BLACK,
        getScale = function()
            return globalScale.get() * 1.5
        end,
    })
    e.continueRunInfo = ui.elements.Text({
        text = "Playtime: HH:MM:SS\nLevel: 12\nPoints: 123/456\n\nPerk: [perk-item]\nPerk description",
        align = "left",
        color = objects.Color.WHITE,
        outline = 1,
        outlineColor = objects.Color.BLACK,
        getScale = globalScale.get,
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

function ContinueRunDialog:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.05, 0.2)

    local title, body = r:splitVertical(1, 4)
    body = body:padRatio(0.1)
    title = title:padRatio(0.1)
        :moveRatio(0, 0.1 * math.sin(love.timer.getTime()))
    local continuePane, startPane = body:splitHorizontal(1, 1)
    local continueInfo, continueButton = continuePane:splitVertical(4, 1)
    continueButton = continueButton:shrinkToAspectRatio(3,1)
    local startInfo, startButton = startPane:splitVertical(4, 1)
    startButton = startButton:shrinkToAspectRatio(3,1)

    self.elements.base:render(r:get())
    self.elements.title:render(title:get())
    self.elements.continueRunInfo:render(continueInfo:get())
    self.elements.continueRunButton:render(continueButton:get())
    self.elements.newRunInfo:render(startInfo:get())
    self.elements.newRunButton:render(startButton:get())

    -- Draw pane separator
    local bx, by, bw, bh = body:get()
    love.graphics.setColor(objects.Color.WHITE)
    love.graphics.line(bx + bw / 2, by, bx + bw / 2, by + bh)
end

return ContinueRunDialog
