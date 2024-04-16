
local lg=love.graphics

local MonsterBar = ui.Element("lootplot.main:MonsterBar")


function MonsterBar:init()
end


function MonsterBar:onRender(x,y,w,h)
    lg.setColor(0.5,0.5,0.5)
    lg.rectangle("fill", x,y,w,h)
end

return MonsterBar
