local fonts = require("client.fonts")
local globalScale = require("client.globalScale")
local helper = require("client.states.helper")


local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")

local UNKNOWN_PERK = localization.localize("Unknown Perk")
local NEW_RUN_STRING = localization.localize("Starting a new\nrun will\noverwrite your\nexisting run.")
local RUN_INFO_STRING = localization.newInterpolator("Level: %{level}\nRound: %{round}/%{maxRound}\n\nPerk: %{perk}\n%{perkDescription}")



---@class lootplot.singleplayer.ContinueRunDialog: Element
local ContinueRunDialog = ui.Element("lootplot.singleplayer:ContinueRunDialog")

local FONT_SIZE = 32
local BACKGROUND_COLOR = objects.Color(objects.Color.HSLtoRGB(250, 0.1, 0.32))
local KEYS = {
    runInfo = true,
    continueRun = true,
    startRun = true
}

function ContinueRunDialog:init(args)
    typecheck.assertKeys(args, KEYS)

    self.isQuitting = false

    ---@type lootplot.singleplayer.RunMeta
    local runInfo = args.runInfo
    local perkEType = client.entities[runInfo.perk]
    local friendlyRunInfo = {
        level = runInfo.level,
        round = runInfo.round,
        maxRound = runInfo.maxRound,
        perk = perkEType and (perkEType.name or runInfo.perk) or UNKNOWN_PERK, ---@diagnostic disable-line: undefined-field
        perkDescription = tostring(perkEType and perkEType.description or ""), ---@diagnostic disable-line: undefined-field
    }

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
        onClick = args.startRun,
        text = "Start New Run",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })
    e.continueRunButton = StretchableButton({
        onClick = args.continueRun,
        text = "Continue Run",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(184, 0.7, 0.5),
        font = fonts.getLargeFont(),
    })
    e.exitButton = StretchableButton({
        text = "X",
        scale = 2,
        color = objects.Color(1,1,1,1):setHSL(340, 0.7, 0.5),
        font = fonts.getLargeFont(),
        onClick = function()
            -- leave game:
            self.isQuitting = true
            client.disconnect()
        end,
    })
    e.newRunInfo = ui.elements.Text({
        text = NEW_RUN_STRING,
        color = objects.Color.WHITE,
        outline = 1,
        outlineColor = objects.Color.BLACK,
        getScale = function()
            return globalScale.get() * 1.5
        end,
    })
    e.continueRunInfo = ui.elements.Text({
        text = RUN_INFO_STRING(friendlyRunInfo),
        align = "left",
        color = objects.Color.WHITE,
        outline = 1,
        outlineColor = objects.Color.BLACK,
        getScale = function()
            return globalScale.get() * 1.25
        end,
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

function ContinueRunDialog:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    local r = layout.Region(x,y,w,h):padRatio(0.1, 0.1)

    if self.isQuitting then
        helper.drawQuittingScreen(x,y,w,h)
        return
    end

    local header, body = r:splitVertical(1, 4)
    body = body:padRatio(0.1)
    local title = header:padRatio(0.1)
        :moveRatio(0, 0.1 * math.sin(love.timer.getTime()))

    local _, exitButton = header:padRatio(0.1):splitHorizontal(9,1)
    exitButton = exitButton:padRatio(0.25)

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
    self.elements.exitButton:render(exitButton:get())

    -- Draw pane separator
    local bx, by, bw, bh = body:get()
    love.graphics.setColor(objects.Color.WHITE)
    love.graphics.line(bx + bw / 2, by, bx + bw / 2, by + bh)
end

return ContinueRunDialog
