---@class text.EffectGroup: objects.Class
local EffectGroup = objects.Class("text:EffectGroup")

---@generic T
---@param args T
local function dummyArgTransformer(args)
    return args
end

function EffectGroup:init()
    ---@type {update:fun(context:any,subtext:text.Character,dt:number),maker:fun(args:table<string,number>):any}[]
    self.effectList = {}
end

---Add new effect for rich text formatting.
---
---The `argtransform` argument can be used to convert the effect key-value arguments to any data that the first
---parameter of `effectupdate` accepts. If one is not specified, it defaults to function that simply re-returns
---the effect key-value arguments, in which case the effect key-value arguments will be re-passed to `effectupdate`
---function.
---
---To demonstrate how `argtransform` works, let's say this code
---```lua
---local MyEffect = objects.Class("mymod:MyEffect")
---
---function MyEffect:init(args)
---    self.duration = 0
---    self.speed = args.speed
---end
---
---function MyEffect:update(characters, dt)
---    self.duration = (self.duration + dt * self.speed) % 1
---    for i, char in ipairs(characters) do
---        char:setColor((self.duration + i/127.5) % 1, 1, 1)
---    end
---end
---
---effectGroup:addEffect("pulsered", MyEffect.update, MyEffect)
---```
---With the code above, these will happen:
---* When `"pulsered"` effect is encountered in the text, it calls `MyEffect(args)` where `args` is effect key-values.
---* `MyEffect(args)` will return `MyEffect` object, which is used to replaces `args`.
---* When effects are being applied, `MyEffect.update(args, subtext, dt)` will be called.
---
---Now here's an example of stateless effect:
---```lua
---effectGroup:addEffect("color", function(args, characters)
---    for i, char in ipairs(characters) do
---        char:setColor(args.r, args.g, args.b)
---    end
---end)
---```
---Since `argtransform` is nil, `args` will still be the effect key-value arguments.
---@generic T
---@param name string Effect name.
---@param effectupdate fun(context:T,characters:text.Character[],dt:number) Function that apply the effect to subtext.
---@param argtransform? fun(args:table<string,number>):T Argument transformer function.
function EffectGroup:addEffect(name, effectupdate, argtransform)
    self.effectList[name] = {
        update = effectupdate,
        maker = argtransform or dummyArgTransformer
    }
end

---Get effect info.
---
---This is internal function.
---@param name string Effect name.
function EffectGroup:getEffectInfo(name)
    return self.effectList[name]
end

---Remove the effect.
---@param name string Effect name.
function EffectGroup:removeEffect(name)
    self.effectList[name] = nil
end

if false then
    ---Create new effect group.
    ---@return text.EffectGroup
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function EffectGroup() end
end

---Duplicate the current effect group, copying all the added effects in this effect group to new one.
---@return text.EffectGroup effectgroup The new effect group.
function EffectGroup:clone()
    local result = EffectGroup()
    for k, v in pairs(self.effectList) do
        result.effectList[k] = v
    end

    return result
end

return EffectGroup
