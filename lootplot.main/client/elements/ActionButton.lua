local fonts = require("client.fonts")
local StretchableBox = require("client.elements.StretchableBox")

---@class lootplot.main.ActionButton: Element
local ActionButton = ui.Element("lootplot.main:ActionButton")


local DEFAULT_PADDING = 12

local TABLE_ARGS = {"text", "onClick"}

function ActionButton:init(args)
    typecheck.assertKeys(args, TABLE_ARGS)
    self.click = args.onClick
    self.canClick = args.canClick
    self.padding = args.padding or DEFAULT_PADDING

    if type(args.text) == "function" then
        self.textGetter = args.text
    else
        function self.textGetter()
            return tostring(args.text)
        end
    end

    self.textElement = ui.elements.Text({
        color = objects.Color.WHITE,
        font = fonts.getLargeFont(),
        outline = 1,
        outlineColor = objects.Color.BLACK
    })
    self.box = StretchableBox("orange_big", 8, 8, {
        scale = 2,
        stretchType = "repeat",
    })
    self.box:setContent(self.textElement)
    self:addChild(self.box)
end

if false then
    ---@param args {text:string|(fun():string),onClick:function,canClick:function?,padding:number?}
    ---@return lootplot.main.ActionButton
    function ActionButton(args) end
end

function ActionButton:onRender(x,y,w,h)
    self.textElement:setText(self.textGetter())
    self.box:render(x,y,w,h)
end



function ActionButton:onClick()
    if (self.canClick and self.canClick()) or (not self.canClick) then
        audio.play("lootplot.sound:click", {volume = 0.35, pitch = 1.1})
        self:click()
    else
        audio.play("lootplot.sound:deny_click", {volume = 0.5})
    end
end




return ActionButton

