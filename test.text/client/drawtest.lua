local parsed = assert(text.parseRichText("{wavy}The {c r=0 b=0}quick brown fox jumps over the lazy{/c} dog{/wavy}"))
print(parsed, #text.clear(parsed))

umg.on("@draw", function()
    love.graphics.setColor(1, 1, 1)
    text.printRichText(parsed, love.graphics.getFont(), 0, 0, 200)
end)

local wavyTimer = 0

umg.on("@update", function(dt)
    wavyTimer = wavyTimer + dt
end)

text.defineEffect("wavy", function(args, char)
    local f = args.freq or 1
    local amp = args.amp or 1
    local dy = math.sin(2 * math.pi * f * wavyTimer + char:getIndex() - 1) * amp
    char:setOffset(0, dy)
end)
