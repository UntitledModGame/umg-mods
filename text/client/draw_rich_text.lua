if false then utf8 = require("utf8") end -- sumneko hack

local Pass = require("client.Pass")
local parser = require("client.parser")

-- ---@type text.Pass
-- local passInstance = Pass(nil, 0, "left", nil)
local drawRichText

---Draw rich text.
---@param txt text.ParsedText|string Formatted rich text string or parsed rich text data.
---@param font love.Font Font object to use
---@param limit number Maximum width before word-wrapping.
---@param transform love.Transform Transformation stack to apply.
---@return boolean,(string|nil)
---@diagnostic disable-next-line: missing-return
function drawRichText(txt, font, limit, transform) end

---Draw rich text directly without state.
---@param txt text.ParsedText|string Formatted rich text string or parsed rich text data.
---@param font love.Font Font object to use
---@param x number
---@param y number
---@param limit number Maximum width before word-wrapping.
---@param rot number?
---@param sx number?
---@param sy number?
---@param ox number?
---@param oy number?
---@param kx number?
---@param ky number?
---@return boolean,(string|nil)
function drawRichText(txt, font, x, y, limit, rot, sx, sy, ox, oy, kx, ky)
    if typecheck["love:Transform"](y) then
        limit = x
        x = y
        y = nil
        rot = nil
        sx = nil
        sy = nil
        ox = nil
        oy = nil
        kx = nil
        ky = nil
    end

    love.graphics.push("all")
    love.graphics.applyTransform(x, y, rot, sx, sy, ox, oy, kx, ky)

    local r, g, b, a = love.graphics.getColor()
    local passInstance = Pass(font, limit, "left", {r, g, b, a})

    for _, data in ipairs(assert(parser.ensure(txt))) do
        if type(data) == "table" then
            passInstance:updateEffect(data)
        else
            for _, c in utf8.codes(data) do
                passInstance:add(utf8.char(c))
            end
        end
    end

    passInstance:add(nil) -- flush

    love.graphics.pop()
    return true
end

return drawRichText
