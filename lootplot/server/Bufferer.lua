---@class lootplot.Bufferer: objects.Class
local Bufferer = objects.Class("lootplot:Bufferer")
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

local DEFAULT_BUFFERER_DELAY = 0.2

local CONVERSIONS = objects.Enum({
    ITEM = "ITEM",
    SLOT = "SLOT"
})

function Bufferer:init()
    self.i = 1 -- the current position that we are executing.
    self.positions = objects.Array()-- Array<PPos>

    self.filters = objects.Array() -- Array<filterFunc>

    self.conversion = false -- no conversion; remain as ppos

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
    if plot_or_ppos.plot then
        -- Q: WTF is this code???
        -- Ans: It's converting ppos --> plot.
        plot = plot_or_ppos.plot
    end
    ---@cast plot lootplot.Plot
    plot:foreach(function(pos)
        self:add(pos)
    end)
    return self
end

---@param towhat? "ITEM"|"SLOT"
---@return lootplot.Bufferer
function Bufferer:to(towhat)
    if towhat then
        self.conversion = CONVERSIONS[towhat]
    else
        self.conversion = false
    end

    return self
end

---@param x number
---@return lootplot.Bufferer
function Bufferer:delay(x)
    self._delay = x
    return self
end



local function tryConvert(self, ppos)
    if self.conversion == CONVERSIONS.ITEM then
        return lp.posToItem(ppos)
    elseif self.conversion == CONVERSIONS.SLOT then
        return lp.posToSlot(ppos)
    end
    return nil
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
    local val = tryConvert(self, ppos)
    if self.conversion and (not val) then
        -- no slot, or no item!
        return
    end

    for _, f in ipairs(self.filters) do
        local ok = f(ppos, val)
        if not ok then
            return
        end
    end

    self.execution(ppos, val)

    if self._delay then
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

