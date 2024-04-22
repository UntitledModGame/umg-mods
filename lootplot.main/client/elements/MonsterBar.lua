
local lg=love.graphics

local MonsterBar = ui.Element("lootplot.main:MonsterBar")


function MonsterBar:init(args)
end


function MonsterBar:onRender(x,y,w,h)
    --[[
        TODO: Put some actual SHIT here man!
    ]]
    lg.setColor(0,0,0,1)
    lg.rectangle("fill", x,y,w,h)

    lg.setColor(1,1,1,1)

    -- TODO: this is a BIIIT hacky...
    --  OH WELL LOL!
    local ctx = lp.main.getContext()
    local points = ctx.points 
    lg.print("Points: " .. tostring(points), x,y)
end

return MonsterBar
