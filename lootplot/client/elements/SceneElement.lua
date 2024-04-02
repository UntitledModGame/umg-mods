

local Scene = ui.Element("lootplot:Scene")

local PlotInventoryElement = require("client.elements.PlotInventoryElement")


function Scene:init(args)
    self:makeRoot()
    self:setPassthrough(true)

    typecheck.assertKeys(args, {"shop", "inventory", "world"})

    -- TODO: use more specific elements here-
    -- (ShopElement, WorldElement instead of this generic crap)
    self.shopElem = PlotInventoryElement(args.shop)
    self.inventoryElem = PlotInventoryElement(args.inventory)
    self.worldElem = PlotInventoryElement(args.world)

    self.rerollButton = elements.Button()
    self.playButton = elements.Button()

    self.stack = objects.Array()
end



function Scene:onRender(x,y,w,h) -- dont use these args.
    self.shopElem:render(x,y,w,h)
    self.inventoryElem:render(x,y,w,h)
    self.worldElem:render(x,y,w,h)
end


--[[
    TODO:
    In future, will allow us to push/pop elements
]]
function Scene:pushScreen(element)
    
end

function Scene:popScreen(element)

end



return Scene

