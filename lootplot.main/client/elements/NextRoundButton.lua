
local NextRoundbutton = ui.Element("lootplot.main:NextRoundbutton")



local color = objects.Color(241/255,196/255,15/255,1)

local hovColor = color:clone()
do
local h,s,l = color:getHSL()
hovColor:setHSL(h,s-0.2,l)
end



function NextRoundbutton:init(args)
    self.box = ui.elements.SimpleBox({
        color = color,
        rounding = 4
    })
    self:addChild(self.box)

    self.text = ui.elements.Text({
        text = "Next\nRound"
    })
    self:addChild(self.text)
end



function NextRoundbutton:onClick()
    local ctx = lp.main.getContext()
    if ctx:canGoNextRound() then
        ctx:goNextRound()
    end
end


function NextRoundbutton:onRender(x,y,w,h)
    if self:isHovered() then
        self.box:setColor(hovColor)
    else
        self.box:setColor(color)
    end
    self.box:setThickness(math.floor(love.graphics.getWidth()/160))
    self.box:render(x,y,w,h)

    local r = ui.Region(x,y,w,h):pad(0.08)
    self.text:render(r:get())
end

