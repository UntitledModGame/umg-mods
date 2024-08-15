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

---@param ent Entity
umg.answer("rendering:getRotation", function(ent)
    if ent:hasComponent("joltJuice") then
        local t = love.timer.getTime() - ent.joltJuice.start
        if t >= ent.joltJuice.duration then
            ent:removeComponent("joltJuice")
        else
            return joltFunc(t, ent.joltJuice.duration, ent.joltJuice.freq) * ent.joltJuice.amp
        end
    end

    return 0
end)

---@param ent Entity
umg.answer("rendering:getScale", function(ent)
    if ent:hasComponent("bulgeJuice") then
        local t = love.timer.getTime() - ent.bulgeJuice.start
        if t >= ent.bulgeJuice.duration then
            ent:removeComponent("bulgeJuice")
        else
            return 1 + math.sin(t * math.pi / ent.bulgeJuice.duration) * ent.bulgeJuice.amp
        end
    end

    return 1
end)

---@param ent Entity
---@param freq number
local function getDeny(ent, freq)
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
        return getDeny(ent, ent.denyJuice.xfreq), getDeny(ent, ent.denyJuice.yfreq)
    end

    return 0,0
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
umg.answer("rendering:getScaleXY", function(ent)
    if ent:hasComponent("flipJuice") then
        return handleFlipJuice(ent) or 1, 1
    end

    return 1,1
end)

umg.answer("rendering:getRotation", function(ent)
    if ent:hasComponent("flipJuice") then
        return (1 - (handleFlipJuice(ent) or 1)) * math.pi / 4
    end

    return 0
end)


---@param ent lootplot.LayerEntity
umg.on("lootplot:entityActivated", function(ent)
    if ent.drawable then
        local duration = 0.33
        local start = love.timer.getTime()
        ent:addComponent("joltJuice", {freq = 2, amp = math.rad(20), start = start, duration = duration})
        ent:addComponent("bulgeJuice", {amp = 0.15, start = start, duration = duration})
    end
end)

---@param selected lootplot.Selected?
umg.on("lootplot:selectionChanged", function(selected)
    if selected then
        local itemEnt = lp.slotToItem(selected.slot)

        if itemEnt then
            itemEnt:addComponent("bulgeJuice", {amp = 0.3, start = love.timer.getTime(), duration = 0.4})
        end
    end
end)

---@param ent lootplot.LayerEntity
umg.on("lootplot:entityActivationBlocked", function(ent)
    if ent.drawable then
        ent:addComponent("denyJuice", {xfreq = 18, yfreq = 0, amp = 1, start = love.timer.getTime(), duration = 0.3})
    end
end)

---@param ent lootplot.LayerEntity
umg.on("lootplot:entitySpawned", function(ent)
    if ent.drawable then
        ent:addComponent("flipJuice", {start = love.timer.getTime(), duration = 0.4})
    end
end)
