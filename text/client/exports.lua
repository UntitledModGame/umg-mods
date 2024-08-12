---@meta

local text = {}
if false then _G.text = text end

text.EffectGroup = require("client.EffectGroup")
text.RichText = require("client.Text")

---@class text.TextArgs
---@field public variables? table<string, any> Variable store to use (defaults to _G).
---@field public effectGroup? text.EffectGroup Effect group to use (defaults to default effect group).

local defaultEffectGroup = require("client.defaultEffectGroup")

local INVALID_CHARS = ".%:{}"
local function assertNameValid(name)
    for ci = 1,#INVALID_CHARS do
        local c = INVALID_CHARS:sub(ci,ci)
        if name:find("%"..c) then
            umg.melt("Invalid character in name:  " .. c, 3)
        end
    end
end

--- Define a new effect for rich text formatting 
---@generic T
---@param name string Effect name.
---@param effectupdate fun(context:T,characters:text.Character) Function that apply the effect to subtext.
function text.defineEffect(name, effectupdate)
    assertNameValid(name)
    return defaultEffectGroup:addEffect(name, effectupdate)
end

---Remove the effect from the default effect group.
---@param name string Effect name.
function text.removeEffect(name)
    return defaultEffectGroup:removeEffect(name)
end

---Duplicate the default effect group, inheriting all the added effects in the default effect group to new independent
---effect group.
---@return text.EffectGroup effectgroup The new effect group.
function text.cloneDefaultEffectGroup()
    return defaultEffectGroup:clone()
end

---@module "client.parser"
local parser = require("client.parser")

---Parse rich text to a table of text and effects.
---Note that this only parses the rich text and does not applies effect.
---@param txt string Formatted rich text
---@return text.ParsedText?,string?
function text.parseRichText(txt)
    return parser.ensure(txt)
end

text.parsedToString = parser.tostring
text.escape = parser.escape

---Clear tags on rich text.
---@param txt text.ParsedText|string
---@return string
function text.clear(txt)
    local parsed = assert(parser.ensure(txt))
    local result = {}

    for _, data in ipairs(parsed) do
        if type(data) == "string" then
            result[#result+1] = data
        end
    end

    return table.concat(result)
end

local drawRichText = require("client.draw_rich_text")
text.printRichText = drawRichText

---@param txt text.ParsedText|string
---@param font love.Font
---@param x number
---@param y number
---@param limit number
---@param rot number?
---@param sx number?
---@param sy number?
function text.printRichTextCentered(txt, font, x, y, limit, rot, sx, sy)
    local parsed = assert(parser.ensure(txt))
    local clear = text.clear(txt)
    local width, wrap = font:getWrap(clear, limit)

    local ox = width / 2
    local oy = #wrap * font:getHeight() / 2
    return drawRichText(parsed, font, x, y, limit, rot, sx, sy, ox, oy)
end

umg.expose("text", text)
require("client.base_effect")() -- Expose default effects

return text
