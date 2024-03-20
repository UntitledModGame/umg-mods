
local SIZE = 400

umg.defineEntityType("magzone", {
    drawable = true,
    magentaZone = true,
    drawDepth = -SIZE,
    size = SIZE,
    onDraw = function(ent)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1,0,1)
        love.graphics.circle("line", ent.x, ent.y, SIZE)
    end,
    
    initXY = true
})




umg.defineEntityType("yellowzone", {
    drawable = true,
    yellowZone = true,
    drawDepth = -SIZE,
    size = SIZE,
    onDraw = function(ent)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1,1,0)
        love.graphics.circle("line", ent.x, ent.y, SIZE)
    end,
    
    initXY = true
})




umg.defineEntityType("cyanzone", {
    drawable = true,
    cyanZone = true,
    drawDepth = -SIZE,
    size = SIZE,
    onDraw = function(ent)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(0,1,1)
        love.graphics.circle("line", ent.x, ent.y, SIZE)
    end,
    
    initXY = true
})


