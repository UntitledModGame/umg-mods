
--[[


---@param x number
local function quint(x)
    return x * x * x * x * x
end

---@param x number
local function sine(x)
    return math.sin(x * math.pi / 2)
end

---@param f fun(x:number):number
local function makeOut(f)
    ---@param x number
    return function(x)
        return 1 - f(1 - x)
    end
end

local outQuint = makeOut(quint)

---@param t number
---@param duration number
---@param freq number
local function joltFunc(t, duration, freq)
    local x = t / duration
    local f = math.sin(math.sqrt(x) * math.pi * freq)
    local ease

    if x < 0.2 then
        ease = outQuint(x / 0.2)
    else
        ease = (1 - sine((x - 0.2) / 0.8))
    end

    return ease * f
end




ent:addComponent("rotationJuice", {
    start = love.timer.getTime(), 
    duration = 2,
    transition = math.sin

    --optional
    multiplier = math.rad(30), 
    offset = 0,
})


ent:addComponent("scaleXYJuice", {
    start = love.timer.getTime(), 
    duration = 2,

    x = {
        transition = math.sin
        multiplier = math.rad(30), 
        offset = 0,
    },
    y = {
        transition = math.cos
        multiplier = math.rad(30), 
        offset = 0,
    }
})



]]



---@class juice._ValueGetter
---@field public transition fun(number): number
---@field public multiplier? number
---@field public offset? number




---@param comp {duration:number, start:number}|juice._ValueGetter
---@return number|false
local function getValue(comp)
    local t = (love.timer.getTime() - comp.start) / comp.duration
    if t > 1 then
        return false
    end
    return (comp.offset or 0) + (comp.multiplier or 1) * comp.transition(t)
end



---@param comp {duration:number, start:number, x?: juice._ValueGetter, y?: juice._ValueGetter}
---@param default number
---@return number|false, number|false
local function getValue2(comp, default)
    local t = (love.timer.getTime() - comp.start) / comp.duration
    if t > 1 then
        return default, default
    end
    local x, y = default, default
    do
        local getter = comp.x
        if getter then
            local func = getter.transition
            local cache = func(t)
            x = (getter.offset or 0) + (getter.multiplier or 1) * func(t)
        end
    end
    do
        local getter = comp.y
        if getter then
            local func = getter.transition
            local cache = func(t)
            y = (getter.offset or 0) + (getter.multiplier or 1) * func(t)
        end
    end
end



---@param ent Entity
umg.answer("rendering:getRotation", function(ent)
    if ent:hasComponent("rotationJuice") then
        local val = getValue(ent.rotationJuice)
        if not val then
            ent:removeComponent("rotationJuice")
        else
            return val
        end
    end

    return 0
end)



---@param ent Entity
umg.answer("rendering:getScale", function(ent)
    if ent:hasComponent("scaleJuice") then
        local val = getValue(ent.scaleJuice)
        if not val then
            ent:removeComponent("scaleJuice")
        else
            return val
        end
    end

    return 1
end)



---@param ent Entity
---@param freq number
local function handleDenyJuice(ent, freq)
    local t = love.timer.getTime() - ent.denyJuice.start
    if t >= ent.denyJuice.duration then
        ent:removeComponent("denyJuice")
        return 0
    else
        return math.sin(t * math.pi * freq) * ent.denyJuice.amp
    end
end


---@param ent Entity
umg.answer("rendering:getOffsetXY", function(ent)
    if ent:hasComponent("denyJuice") then
        return handleDenyJuice(ent, ent.denyJuice.xfreq),0
    end
    return 0,0
end)




---@param ent Entity
umg.answer("rendering:getScaleXY", function(ent)
    if ent:hasComponent("flipJuice") then
        return handleFlipJuice(ent) or 1, 1
    end
    return 1, 1
end)
