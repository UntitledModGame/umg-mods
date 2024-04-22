
local Bufferer = objects.Class("lootplot:Bufferer")
--[[


lp.Bufferer()
    -- a `Bufferer` is a data structure that executes code, buffered
    :touching(ent)
    :filter(func) -- func(ppos) -> bool
    :items() -- ppos-->item
    :delay(0.1) -- 0.1 delay between each execution
    :execute(function()
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

function Bufferer:add(ppos)
    posTc(ppos)
    self.positions:add(ppos)
    return self
end

function Bufferer:touching(ent)
    --TODO: wire this up with shape API
    local ppos = lp.getPos(ent)
    self:add(ppos)
    umg.melt("NYI")
    return self
end

function Bufferer:all(plot_or_ppos)
    assert(plot_or_ppos, "needs plot as arg")
    local plot = plot_or_ppos
    if plot_or_ppos.plot then
        -- Q: WTF is this code???
        -- Ans: It's converting ppos --> plot.
        plot = plot_or_ppos.plot
    end
    plot:foreach(function(pos)
        self:add(pos)
    end)
    return self
end


function Bufferer:items()
    self.conversion = CONVERSIONS.ITEM
    return self
end

function Bufferer:slots()
    self.conversion = CONVERSIONS.SLOT
    return self
end


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

function Bufferer:execute(func)
    funcTc(func)
    assert(not self.execution, "wot? cant use a buffer twice bruv")
    self.execution = func
    finalize(self)
end


function Bufferer:filter(func)
    --[[
        func: function(ppos, itemEnt|slotEnt|nil) -> boolean
    ]]
    funcTc(func)
    self.filters:add(func)
    return self
end




return Bufferer

