
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
    ITEM = true,
    SLOT = true
})

function Bufferer:init()
    self.i = 1 -- the current position that we are executing.
    self.positions = objects.Array()-- Array<PPos>

    self.filters = objects.Array() -- Array<filterFunc>

    self.conversion = false -- no conversion; remain as ppos

    self._delay = DEFAULT_BUFFERER_DELAY
    self.execution = objects.Array()
end



local addTc = typecheck.assert("ppos")

function Bufferer:add(ppos)
    addTc(ppos)
    self.positions:add(ppos)
end

function Bufferer:touching(ent)
    --TODO: wire this up with shape API
    local ppos = lp.getPos(ent)
    self:add(ppos)
end


function Bufferer:items()
    self.conversion = CONVERSIONS.ITEM
end

function Bufferer:slots()
    self.conversion = CONVERSIONS.SLOT
end


function Bufferer:delay(x)
    self._delay = self._delay + x
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

Hmm.. this will be hard to implement.
I think the "only" real way we can implement this is by
pushing a TONNE of functions to the pipeline, 
and doing the filters in-place, within the functions.
    That is, IF we only push to the pipeline once...


ALTERNATIVELY:
----------
What happens if we push to the pipeline multiple times?
Ie; encapsulate each bufferer function as some `Instruction` object,
And then, instructions will push the next instruction once they r done executing.
Like a big linked-list.

Do some thinking.
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
    for i, ppos in ipairs(self.positions) do
        lp.buffer(ppos, function()
            step(self, ppos)
        end)
    end
end



function Bufferer:execute(func)
    assert((not func) or type(func)=="function", "?")
    self.execution = func
    finalize(self)
end



local funcTc = typecheck.assert("function")

function Bufferer:filter(func)
    --[[
        filter: function(ppos, itemEnt|slotEnt|nil) -> boolean
    ]]
    funcTc(func)
    self.filters:add(func)
end




return Bufferer

