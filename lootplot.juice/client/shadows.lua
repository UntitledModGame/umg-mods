


local lg=love.graphics

local ORDER = -10

umg.on("rendering:drawEntity", ORDER, function(ent, x,y, ...)
    if ent.image then
        -- draw shadow
        local offset = 1
        if ent.slot then
            offset = 3
        end

        -- error([[
        --     todo: make not hardcoded
        --     should have `ent.imageShadow = { offset = N }`

        --     create lp:defineSlot and lp:defineItem callbacks.
        --     Add shadow there
        -- ]])
        
        lg.push("all")
        lg.setColor(0,0,0,0.4)
        rendering.drawImage(ent.image, x+offset,y+offset, ...)
        lg.pop()
    end
end)

