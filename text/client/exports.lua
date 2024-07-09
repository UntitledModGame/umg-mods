---@meta

local text = {}
if false then _G.text = text end

text.EffectGroup = require("client.EffectGroup")
text.Text = require("client.Text")

---@class text.TextArgs
---@field public font? love.Font Font object to use (defaults to current font).
---@field public variables? table<string, any> Variable store to use (defaults to _G).
---@field public effectGroup? text.EffectGroup Effect group to use (defaults to default effect group).
---@field public maxWidth? number Maximum width of the text before it can go to the next line.

local defaultEffectGroup = require("client.defaultEffectGroup")

---Add new effect for rich text formatting to the default effect group.
---@generic T
---@param name string Effect name.
---@param effectupdate fun(context:T,subtexts:text.SubText[],dt:number) Function that apply the effect to subtext.
---@param argtransform? fun(args:table<string,number>):T Argument transformer function.
function text.addEffect(name, effectupdate, argtransform)
    return defaultEffectGroup:addEffect(name, effectupdate, argtransform)
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

umg.expose("text", text)

return text
