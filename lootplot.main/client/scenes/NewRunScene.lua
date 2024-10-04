local fonts = require("client.fonts")

local StretchableBox = require("client.elements.StretchableBox")
local StretchableButton = require("client.elements.StretchableButton")


---@class lootplot.main.NewRunScene: Element
local NewRunScene = ui.Element("lootplot.main:NewRunScene")

---@param args table
function NewRunScene:init(args)
    -- Layouts
    local NLay = layout.NLay
    local l = {}
    -- The dialogue box
    l.root = NLay.contain(NLay.constraint(NLay, NLay, NLay, NLay, NLay, 48)
        :size(0, 0))
        :ratio(3, 2)
    -- Text that says "New Run"
    l.title = NLay.constraint(l.root, l.root, l.root, nil, l.root)
        :size(-1, 50)
    -- Button container
    l.buttons = NLay.constraint(l.root, nil, l.root, l.root, l.root)
        :size(-1, 50)
    -- Button that says "Start"
    l.startButton = NLay.constraint(l.buttons, l.buttons, l.buttons, l.buttons, l.buttons, 4)
        :size(200, -1)
    -- Content area
    l.content = NLay.constraint(l.root, l.title, l.root, l.buttons, l.root)
        :size(-1, 0)
    -- perksImageBase is the text that says "Perk" and the large perk image.
    -- perksInfo is the text that says "Golden-perk".
    -- perksSelectBase is the grid layout for selecting perk.
    l.perksImageBase, l.perksInfo, l.perksSelectBase = NLay.split(l.content, "horizontal", 2, 3, 2)
    -- Text that says "Perk"
    l.perkText = NLay.constraint(l.perksImageBase, l.perksImageBase, l.perksImageBase, nil, l.perksImageBase)
        :size(-1, 32)
    -- Large perk item image
    l.perkImage = NLay.contain(NLay.constraint(l.perksImageBase, l.perkText, l.perksImageBase, l.perksImageBase, l.perksImageBase, 8)
        :size(-1, 0))
        :bias(nil, 0) -- align ratio constraint to the top
    -- Perk description (the one that says "Golden-perk")
    l.perkDescription = NLay.constraint(l.perksInfo, NLay.in_(l.perkImage), l.perksInfo, l.perksInfo, l.perksInfo, 8)
        :size(-1, 0)
    -- Container to contain the grid layout (as NLay.grid will modify them)
    l.perksSelectBase:margin(8)
    local perksSelectContainer = NLay.constraint(l.perksSelectBase, l.perksSelectBase, l.perksSelectBase, l.perksSelectBase, l.perksSelectBase)
        :bias(1, 0)
    -- Perk grid
    l.perkGrid = NLay.grid(perksSelectContainer, 5, 3, {
        cellwidth = 10, cellheight = 10, -- set later
    })
    self.layout = l

    -- Elements
    local e = {}
    e.base = StretchableBox("orange_pressed_big", 8, {
        stretchType = "repeat",
        scale = 2
    })
    e.title = ui.elements.Text({
        text = "New Run",
        color = objects.Color.WHITE,
        font = fonts.getLargeFont(),
    })
    e.startButton = StretchableButton({
        onClick = function() end,
        text = "Start Run",
        color = objects.Color.DARK_GREEN,
        font = fonts.getLargeFont(),
    })
    e.perkText = ui.elements.Text({
        text = "Perk",
        font = fonts.getSmallFont(),
    })

    for _, v in pairs(e) do
        self:addChild(v)
    end
    self.elements = e
end

---@param text string
---@param constraint NLay.BaseConstraint
local function drawTextIn(text, constraint)
    local x, y, w, h = constraint:get()
    return love.graphics.printf(text, fonts.getSmallFont(32), x, y, w, "left")
end

---@param constraint NLay.BaseConstraint
local function drawRectangleByConstraint(constraint)
    return love.graphics.rectangle("line", constraint:get())
end

function NewRunScene:onRender(x, y, w, h)
    love.graphics.setColor(objects.Color.WHITE)
    self.elements.base:render(self.layout.root:get())
    self.elements.title:render(self.layout.title:get())
    self.elements.startButton:render(self.layout.startButton:get())
    self.elements.perkText:render(self.layout.perkText:get())

    love.graphics.setColor(objects.Color.BLACK)
    drawTextIn("Golden-perk:\nStart the game with 3 extra shop slots", self.layout.perkDescription)

    love.graphics.setColor(objects.Color.WHITE)
    drawRectangleByConstraint(self.layout.perkImage)
    -- Update cell sizes
    local cellsize = select(3, self.layout.perksSelectBase:get()) / 3
    self.layout.perkGrid:cellSize(cellsize, cellsize)
    self.layout.perkGrid:foreach(drawRectangleByConstraint)
end

return NewRunScene
