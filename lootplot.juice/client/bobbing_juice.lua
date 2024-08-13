


local function getSineInput(offset, period)
    local t = (love.timer.getTime() + offset) % period
    return 2 * math.pi * t / period
end



local group = umg.group("item")
group:onAdded(function(ent)
    ent.bobbingJuice = {period = 0.5}
end)

umg.answer("rendering:getOffsetXY", function(ent)
    if ent:hasComponent("bobbingJuice") then
        -- Compute offset
        local offset = ent.bobbingJuice.offset
        local amplitude = ent.bobbingJuice.amplitude or 0.25
        local period = ent.bobbingJuice.period

        if not offset then
            offset = ((ent.id * 131071) % 10000) / 10000
        end
        local t = getSineInput(offset, period)

       return 0, math.sin(t) * amplitude
    end

    return 0,0
end)



local group = umg.group("slot")
group:onAdded(function(ent)
    ent.bobbingJuice = {period = 1.5}
end)

umg.answer("rendering:getScaleXY", function(ent)
    if ent:hasComponent("bulgingJuice") then
        local comp = ent.bulgingJuice
        local offset = comp.offset
        local period = comp.period
        local ampl = comp.amplitude or 0.1

        if not offset then
            offset = ((ent.id * 131071) % 10000) / 10000
        end
        local t = getSineInput(offset, period)

        local sx = 1 + math.sin(t) * ampl
        local sy = 1 - math.sin(t) * ampl
        return sx, sy
    end
    return 1,1
end)
