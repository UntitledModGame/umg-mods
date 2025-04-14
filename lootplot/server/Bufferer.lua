--[[


lp.Bufferer()
    -- a `Bufferer` is a data structure that executes code, buffered
    :addAll(targets)
    :filter(func) -- func(ppos) -> bool
    :to("item" or "slot") -- ppos-->item or ppos->slot
    :delay(0.1) -- 0.1 delay between each execution
    :execute(function(ppos, item_or_slot)
        -- Do something with `touching` items:
        ...
    end)



]]

local DEFAULT_BUFFERER_DELAY = 0.3




---@class lootplot.Bufferer: objects.Class
---@field public targetType lootplot.CONVERSION_TYPE?
local Bufferer = objects.Class("lootplot:Bufferer")


function Bufferer:init()
    self.i = 1 -- the current position that we are executing.
    self.positions = objects.Array()-- Array<PPos>

    self.filters = objects.Array() -- Array<filterFunc>

    self.targetType = nil -- false = remain as ppos

    self._delay = DEFAULT_BUFFERER_DELAY
    self.execution = false
end



local posTc = typecheck.assert("ppos")
---@param ppos lootplot.PPos
---@return lootplot.Bufferer
function Bufferer:add(ppos)
    posTc(ppos)
    self.positions:add(ppos)
    return self
end

---@param pposes lootplot.PPos[]|objects.Array
function Bufferer:addAll(pposes)
    for _, ppos in ipairs(pposes) do
        self:add(ppos)
    end

    return self
end

---@param plot_or_ppos lootplot.Plot|lootplot.PPos
---@return lootplot.Bufferer
function Bufferer:all(plot_or_ppos)
    assert(plot_or_ppos, "needs plot as arg")
    local plot = plot_or_ppos
    if plot_or_ppos.getPlot then
        -- Q: WTF is this code???
        -- Ans: It's converting ppos --> plot.
        plot = plot_or_ppos:getPlot()
    end
    ---@cast plot lootplot.Plot
    plot:foreach(function(pos)
        self:add(pos)
    end)
    return self
end

---@param towhat? lootplot.CONVERSION_TYPE
---@return lootplot.Bufferer
function Bufferer:to(towhat)
    if towhat then
        self.targetType = lp.CONVERSIONS[towhat]
    else
        self.targetType = nil
    end

    return self
end

---@param x number
---@return lootplot.Bufferer
function Bufferer:withDelay(x)
    self._delay = x
    return self
end



--- Tells the bufferer to delay BEFORE the action occurs instead of after.
--- This is useful for actions that we know will likely be depth-first
--- (IE item-A activates item-B, which activates item-A again, which activates item-B, etc)
--- ^^^ if we dont have this, then the entire action will occur at once which sucks.
---@param x number
function Bufferer:withEarlyDelay(x)
    self._earlyDelay = true
    return self:withDelay(x)
end


--[[
Finalizes the buffer, and pushes a bunch of functions to the bufferer.

I think the "only" real way we can implement this is by
pushing a TONNE of functions to the pipeline, 
and doing the filters in-place, within the functions.
    That is, IF we only push to the pipeline once...
]]

---@param self lootplot.Bufferer
---@param ppos lootplot.PPos
local function step(self, ppos)
    local val = nil
    if self.targetType then
        local ok
        ok, val = lp.tryConvert(ppos, self.targetType)
        if (not ok) then
            -- no slot, or no item!
            return
        end
    end

    for _, f in ipairs(self.filters) do
        local ok1 = f(ppos, val)
        if not ok1 then
            return
        end
    end

    self.execution(ppos, val)

    if self._delay then
        -- LIFO: wait *first*, then execute.
        -- The reason we wait first is because if we have a complex interaction chain,
        -- EG 2 items activating each other,
        -- it'll activate in a depth-first fashion, and 
        -- the delays will stack up at the end.

        -- TRUST ME!!! dont change this to delay after!
        lp.wait(ppos, self._delay)
    end
end


local function finalize(self)
    for _i, ppos in ipairs(self.positions) do
        -- this is quite inefficient! Oh well lol
        lp.queue(ppos, function()
            step(self, ppos)
        end)
    end
end



local funcTc = typecheck.assert("function")
---@param func fun(ppos:lootplot.PPos,ent?:Entity)
function Bufferer:execute(func)
    funcTc(func)
    assert(not self.execution, "wot? cant use a buffer twice bruv")
    self.execution = func
    finalize(self)
end

---@param func fun(ppos:lootplot.PPos,ent?:Entity):boolean
---@return lootplot.Bufferer
function Bufferer:filter(func)
    funcTc(func)
    self.filters:add(func)
    return self
end



---@cast Bufferer +fun():lootplot.Bufferer
return Bufferer

