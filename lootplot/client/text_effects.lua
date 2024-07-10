local wavyTimer = 0

umg.on("@update", function(dt)
    wavyTimer = wavyTimer + dt
end)

text.addEffect("wavy", function(args, characters)
    local f = args.freq or 1
    local amp = args.amp or 1
    for i, char in ipairs(characters) do
        local dy = math.sin(2 * math.pi * f * wavyTimer + i - 1) * amp
        char:setOffset(0, dy)
    end
end)

text.addEffect("u", function(_, characters)
    local r, g, b, a = love.graphics.getColor()

    for _, char in ipairs(characters) do
        local c1, c2, c3, c4 = char:getColor():getRGBA()
        local x, y = char:getPosition()
        local w, h = char:getDimensions()
        love.graphics.setColor(r * c1, g * c2, b * c3, a * c4)
        love.graphics.line(x, y + h - 0.5, x + w, y + h - 0.5)
    end

    love.graphics.setColor(r, g, b, a)
end)

text.addEffect("outline", function(args, characters)
    local thickness = args.thickness or 1
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(0, 0, 0, a)

    for _, char in ipairs(characters) do
        local ox, oy = char:getOffset()

        -- Draw outline
        for i = 0, 8 do
            if i ~= 4 then -- Don't draw the center
                local ooy = (math.floor(i / 3) - 1) * thickness
                local oox = (i % 3 - 1) * thickness
                char:setOffset(ox + oox, oy + ooy)
                char:draw(0, 0, 0, a, true)
            end
        end
        char:setOffset(ox, oy)
    end

    love.graphics.setColor(r, g, b, a)
end)
