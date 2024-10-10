
local fonts = require("client.fonts")
local globalScale = require("client.globalScale")

local runManager = require("shared.run_manager")

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")


local loc = localization.localize

local NEW_RUN_STRING = loc("New Run")




---@class lootplot.main.NewRunDialog: Element
local NewRunDialog = ui.Element("lootplot.main:NewRunDialog")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))

function NewRunDialog:init()
    local e = {}
    e.base = StretchableBox("white_pressed_big", 8, {
        stretchType = "repeat",
        color = BACKGROUND_COLOR,
        scale = 2
    })
    e.title = ui.elements.Text({
        text = NEW_RUN_STRING,
        color = objects.Color.WHITE,
        outline = 2,
        outlineColor = objects.Color.BLACK,
        font = fonts.getLargeFont(FONT_SIZE),
    })
    e.newRunButton = StretchableButton({
        onClick = function()
            return runManager.startRun({
                starterItem = "one_ball",
                seed = "123",
            })
        end,
        text = "Start New Run",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

function NewRunDialog:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.05, 0.2)

    local title, body, footer = r:splitVertical(1, 4, 1)
    body = body:padRatio(0.1)
    title = title:padRatio(0.1)
        :moveRatio(0, 0.1 * math.sin(love.timer.getTime()))
    local left, right = body:splitHorizontal(1, 1)

    local perkTitle, perkSelect = right:splitHorizontal(0.2,1)
    local startButton = footer:padRatio(0.15):shrinkToAspectRatio(3,1)

    self.elements.base:render(r:get())
    self.elements.title:render(title:get())
    self.elements.newRunButton:render(startButton:get())

    -- Draw pane separator
    local bx, by, bw, bh = body:get()
    love.graphics.setColor(objects.Color.WHITE)
    love.graphics.line(bx + bw / 2, by, bx + bw / 2, by + bh)
end

return NewRunDialog

