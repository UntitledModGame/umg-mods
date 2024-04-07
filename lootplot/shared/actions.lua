
--[[

Buffered actions:

For example;
- activating an ent
- swapping items
- destroying an ent

actions are pushed to the pipeline via plot:buffer(f,...)

NOTE: Every action in this file should ALSO be able to be rewritten 
in other mods by calling plot:buffer(f,...)

]]

local actions = {}


local function toBufferedWithPPos(fn)
    local function func(ppos, ...)
        lp.posTc(ppos)
        local plot = ppos.plot
        plot:buffer(fn, ppos, ...)
    end
    return func
end

local entTc = typecheck.assert("entity")
local function toBufferedWithEnt(fn)
    local function func(ent, ...)
        entTc(ent)
        local ppos = lp.getPos(ent)
        -- HMMM::
        -- if ppos is nil here... should we melt??
        if ppos then
            local plot = ppos.plot
            plot:buffer(fn, ppos, ...)
        end
    end
    return func
end





return actions
