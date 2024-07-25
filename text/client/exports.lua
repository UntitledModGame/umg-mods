---@meta

local text = {}
if false then _G.text = text end

text.EffectGroup = require("client.EffectGroup")
text.RichText = require("client.Text")

---@class text.TextArgs
---@field public variables? table<string, any> Variable store to use (defaults to _G).
---@field public effectGroup? text.EffectGroup Effect group to use (defaults to default effect group).

local defaultEffectGroup = require("client.defaultEffectGroup")

---Add new effect for rich text formatting to the default effect group.
---@generic T
---@param name string Effect name.
---@param effectupdate fun(context:T,characters:text.Character) Function that apply the effect to subtext.
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
    return (str:gsub("[{|}]", rep2))
end

local escapermt = {}

function escapermt:__call()
    return string.format("{$%s()}", self.name)
end

function escapermt:__index(k)
    return setmetatable({name = k}, escapermt)
end

function escapermt:__tostring()
    return string.format("{$%s}", self.name)
end

local escaper = setmetatable({name = ""}, escapermt)

---Clear tags on rich text, optionally interpolating them if needed.
---@param str string
---@param variables table<string, any>?
function text.clear(str, variables)
    -- HACK: There should be cleaner way to do this
    local rt = text.RichText(str, {variables = variables or escaper})
    return rt:getString()
end

---@module "client.stateless"
text.printRichText = require("client.stateless")

umg.expose("text", text)
require("client.base_effect")() -- Expose default effects

return text
