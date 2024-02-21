


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
    lg.setColor(0.5,0,5,0.5)
    lg.rectangle("fill",x,y,w,h)
    local r = ui.Region(x,y,w,h)
        :pad(0.1)
    self.button:render(r:get())
end

end

local function toggleUI(ent)
    if ui.isOpen(ent) then
        ui.close(ent)
    else
        ui.open(ent)
    end
end

return {
    image = "crate",

    color = {1,0,0},

    initxy = true,

    onclick = function(ent)
        if client then
            toggleui(ent)
        end
    end,

    initui = function(ent)
        ent.uielement = basicbox()
        uiregion = ui.region(100,100,300,300),
    end
}

