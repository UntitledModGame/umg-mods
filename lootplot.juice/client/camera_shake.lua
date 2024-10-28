local INTENSITY = 5
local SHAKE_DURATION = 0.2

local shakeTime = love.timer.getTime()

umg.on("lootplot:comboChanged", function(_, _, _, combo)
    if combo > 0 and combo % 50 == 0 then
        shakeTime = love.timer.getTime() + SHAKE_DURATION
    end
end)

umg.answer("rendering:getCameraOffset", function()
    local t = love.timer.getTime()
    if t >= shakeTime then
        return 0, 0
    end

    local amp = math.sin(2 * math.pi * (shakeTime - t) / SHAKE_DURATION)
    local y = amp * INTENSITY
    return 0, y
end)
