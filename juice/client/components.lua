
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


]]


local function type()

end


---@param ent Entity
umg.answer("rendering:getRotation", function(ent)
    if ent:hasComponent("rotationJuice") then
        local t = love.timer.getTime() - ent.rotationJuice.start
        if t >= ent.rotationJuice.duration then
            ent:removeComponent("rotationJuice")
        else
            return joltFunc(t, ent.rotationJuice.duration, ent.rotationJuice.freq) * ent.rotationJuice.amp
        end
    end

    return 0
end)



---@param ent Entity
umg.answer("rendering:getScale", function(ent)
    if ent:hasComponent("scaleJuice") then
        local t = love.timer.getTime() - ent.scaleJuice.start
        if t >= ent.scaleJuice.duration then
            ent:removeComponent("scaleJuice")
        else
            return 1 + math.sin(t * math.pi / ent.scaleJuice.duration) * ent.scaleJuice.amp
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
umg.answer("rendering:getOffsetX", function(ent)
    if ent:hasComponent("denyJuice") then
        return handleDenyJuice(ent, ent.denyJuice.xfreq)
    end
    return 0
end)

---@param ent Entity
umg.answer("rendering:getOffsetY", function(ent)
    if ent:hasComponent("denyJuice") then
        return handleDenyJuice(ent, ent.denyJuice.yfreq)
    end
    return 0
end)



---@param ent Entity
local function handleFlipJuice(ent)
    local t = love.timer.getTime() - ent.flipJuice.start
    if t >= ent.flipJuice.duration then
        ent:removeComponent("flipJuice")
        return nil
    else
        return t / ent.flipJuice.duration
    end
end

---@param ent Entity
umg.answer("rendering:getScaleX", function(ent)
    if ent:hasComponent("flipJuice") then
        return handleFlipJuice(ent) or 1
    end
    return 1
end)

umg.answer("rendering:getRotation", function(ent)
    if ent:hasComponent("flipJuice") then
        return (1 - (handleFlipJuice(ent) or 1)) * math.pi / 4
    end
    return 0
end)

