


local RerollElement
if client then

RerollElement = ui.Element("lootplot:RerollElement")

function RerollElement:init()
    self.button = ui.elements.Button({
        onClick = function(world)
        end,
        text = "Reroll"
    })
end

function RerollElement:onRender(x,y,w,h)
    -- todo: uncomment this::
    -- self.button.text = "Reroll - $" .. getMoney(client.getClient())
    self.button:render(x,y,w,h)
end

end


umg.defineEntityType("rerollButton", {


})

