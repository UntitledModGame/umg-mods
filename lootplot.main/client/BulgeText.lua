---@class lootplot.main.BulgeText: text.Text
local BulgeText = objects.Class("lootplot.main:BulgeText"):implement(text.Text)

function BulgeText:init(txt, args)
    text.Text.init(self, txt, args)
    self.constructTime = love.timer.getTime()
    self.timeStepPerCharacter = args and args.stepPerChar or 0.05 -- 50ms
    self.totalDurationPerCharacter = args and args.bulgeDuration or 0.2 -- 200ms
end

---@param char text.Character
function BulgeText:effectCharacter(char)
    local progress = love.timer.getTime() - self.constructTime
    local index = char:getIndex()

    local currentCharacterProgress = progress - index * self.timeStepPerCharacter
    local height = select(2, char:getDimensions())
    char:setOffset(0, height / 2)

    -- This is very complex invented formula to mimicks balatro's text effect
    -- What we want is to scale up to 1.5x (or 2x) at certain point then scale down to 1x
    local charProgress01 = math.min(math.max(currentCharacterProgress, 0), self.totalDurationPerCharacter) / self.totalDurationPerCharacter
    local scale = 1.5 * math.sin(charProgress01 * math.pi) ^ 2
    if charProgress01 >= 0.5 then
        scale = math.max(scale, 1)
    end
    char:setScale(scale, scale)
end

function BulgeText:draw(x, y, maxwidth, rot, sx, sy, ox, oy, kx, ky)
    love.graphics.push()
    love.graphics.translate(0, self.fontHeight / 2)
    text.Text.draw(self, x, y, maxwidth, rot, sx, sy, ox, oy, kx, ky)
    love.graphics.pop()
end

if false then
    ---@param text string
    ---@param args? text.TextArgs|{stepPerChar:number?,bulgeDuration:number?}
    ---@return text.Text
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function BulgeText(text, args) end
end

return BulgeText
