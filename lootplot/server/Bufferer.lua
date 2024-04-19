
local Bufferer = objects.Class("lootplot:Bufferer")
--[[


lp.Bufferer()
    -- a `Bufferer` is a data structure that executes code, buffered
    :touching(ent)
    :filter(func) -- func(ppos) -> bool
    :items() -- ppos-->item
    :execute(function()
        -- Do something with `touching` items:
        ...
    end)





]]

function Bufferer:init()
end



function Bufferer:add(ppos)
    -- adds a `ppos` to the execution pipeline
end

function Bufferer:touching(ent)
end

function Bufferer:filter(f)
end


function Bufferer:items()
end

function Bufferer:slots()
end


function Bufferer:execute(func)
    -- 
end


function Bufferer:finalize()
    --[[
        Finalizes the buffer, and pushes a bunch of functions to the bufferer.

        Hmm.. this will be hard to implement.
        I think the "only" real way we can implement this is by
        pushing a TONNE of functions to the pipeline, 
        and doing the filters in-place, within the functions.
            That is, IF we only push to the pipeline once...
        
        What happens if we push to the pipeline multiple times?
        Ie; encapsulate each bufferer function as some `Instruction` object,
        And then, instructions will push the next instruction once they r done executing.
        Like a big linked-list.

        Do some thinking.
    ]]
end




return Bufferer

