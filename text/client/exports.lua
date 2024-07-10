---@meta

local text = {}
if false then _G.text = text end

text.EffectGroup = require("client.EffectGroup")
text.Text = require("client.Text")

---@class text.TextArgs
---@field public font? love.Font Font object to use (defaults to current font).
---@field public variables? table<string, any> Variable store to use (defaults to _G).
---@field public effectGroup? text.EffectGroup Effect group to use (defaults to default effect group).

local defaultEffectGroup = require("client.defaultEffectGroup")

---Add new effect for rich text formatting to the default effect group.
---@generic T
---@param name string Effect name.
---@param effectupdate fun(context:T,characters:text.Character[]) Function that apply the effect to subtext.
function text.addEffect(name, effectupdate)
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

---@param s string
local function rep2(s)
    return s:rep(2)
end

---Escape effect tag and string interpolation in the text.
---@param str string
function text.escape(str)
    return str:gsub("[{|}]", rep2)
end

umg.expose("text", text)
require("client.base_effect")() -- Expose default effects

return text
