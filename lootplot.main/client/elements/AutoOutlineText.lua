local globalScale = require("client.globalScale")

---@class lootplot.main.AutoOutlineText: Element
local AutoOutlineText = ui.Element("lootplot.main:AutoOutlineText")

local AUTO_OUTLINE_TEXT_KEYS = {text = true, outline = true}

---@param args {text:string,wrap:boolean?,font:love.Font?,scale:number?,align:love.AlignMode?,color:objects.Color?,outline:number,outlineColor:objects.Color?}
function AutoOutlineText:init(args)
    typecheck.assertKeys(args, AUTO_OUTLINE_TEXT_KEYS)
    self.outline = args.outline
    self.text = ui.elements.Text(args)
    self:addChild(self.text)
end

if false then
    ---@param args {text:string,wrap:boolean?,font:love.Font?,scale:number?,align:love.AlignMode?,color:objects.Color?,outline:number,outlineColor:objects.Color?}
    ---@return lootplot.main.AutoOutlineText
    function AutoOutlineText(args) end
end

function AutoOutlineText:getText()
    return self.text:getText()
end

function AutoOutlineText:setText(text)
    return self.text:setText(text)
end

function AutoOutlineText:onRender(x, y, w, h)
    self.text.outline = self.outline-- * globalScale.get()
    return self.text:render(x, y, w, h)
end

return AutoOutlineText
