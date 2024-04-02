

local Scene = ui.Element("lootplot:Scene")


function Scene:init(args)
    self:makeRoot()
    self:setPassthrough(true)

    typecheck.assertKeys(args, {"shop", "inventory", "world"})

    -- ents:
    self.shop = args.shop
    self.inventory = args.inventory
    self.world = args.world

    self.stack = objects.Array()
end


function Scene:onRender(x,y,w,h) -- dont use these args.
    do return end
    self.shop:render()
    self.inventory:render()
    self.world:render()
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

