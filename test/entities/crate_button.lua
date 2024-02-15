


local BasicBox

if client then

local lg = love.graphics
BasicBox = ui.Element("ui:BasicBox")

function BasicBox:init()
    self.button = ui.elements.Button({
        onClick = function()
            print("Basic box clicked")
        end,
        text = "BASIC BOX"
    })
    self:addChild(self.button)
end


function BasicBox:onRender(x,y,w,h)
    lg.setColor(1,1,1)
    lg.rectangle(x,y,w,h)
    local r = ui.Region(x,y,w,h)
        :pad(0.1)
    self.button:render(r:get())
end

end



return {
    image = "crate",

    uiRegion = {100,100,300,300},

    initXY = true,

    onClick = function(ent)
        if client then
            ui.open(ent)
        end
    end,

    initUI = function(ent)
        ent.uiElement = BasicBox()
    end
}

