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



---@param ent lootplot.LayerEntity
umg.on("lootplot:entityActivated", function(ent)
    if ent.drawable then
        ent:addComponent("rotationJuice", {freq = 2, amp = math.rad(30), start = love.timer.getTime(), duration = 2})
    end
end)

---@param selected lootplot.Selected?
umg.on("lootplot:selectionChanged", function(selected)
    if selected then
        local itemEnt = lp.slotToItem(selected.slot)

        if itemEnt then
            itemEnt:addComponent("scaleJuice", {amp = 0.2, start = love.timer.getTime(), duration = 0.5})
        end
    end
end)

---@param ent lootplot.LayerEntity
umg.on("lootplot:entityActivationBlocked", function(ent)
    if ent.drawable then
        ent:addComponent("denyJuice", {xfreq = 15, yfreq = 0, amp = 2, start = love.timer.getTime(), duration = 0.6})
    end
end)

---@param ent lootplot.LayerEntity
umg.on("lootplot:entitySpawned", function(ent)
    if ent.drawable then
        ent:addComponent("flipJuice", {start = love.timer.getTime(), duration = 0.4})
    end
end)
