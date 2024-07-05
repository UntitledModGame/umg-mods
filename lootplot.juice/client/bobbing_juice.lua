local PERIOD = 0.5

local group = umg.group("item")
group:onAdded(function(ent)
    ent.bobbingJuice = {period = PERIOD}
end)

---@param ent Entity
umg.answer("rendering:getOffsetY", function(ent)
    if ent:hasComponent("bobbingJuice") then
        -- Compute offset
        local offset = ent.bobbingJuice.offset
        local period = ent.bobbingJuice.period

        if not offset then
            offset = ((ent.id * 131071) % 10000) / 10000
        end

        local t = (love.timer.getTime() + offset) % period
        return math.sin(2 * math.pi * t / period) * 0.25
    end

    return 0
end)
