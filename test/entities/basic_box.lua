


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
    lg.setColor(0.5,0.5,0.5)
    lg.rectangle("fill",x,y,w,h)
    local r = ui.Region(x,y,w,h)
        :pad(0.2)
    self.button:render(r:get())
end

end



umg.defineEntityType("basic_box", {
    image = "crate",

    color = {1,0,0},

    initXY = true,

    basicUI = {
        interactionDistance = 450
    },

    uiSize = {
        width = 0.4,
        height = 0.2,
        widthFactorOf = 400
    },

    initUI = function(ent)
        ent.ui = {
            element = BasicBox(),
            region = ui.Region(100,100,300,300)
        }
    end
})

