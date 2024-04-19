
--[[

Position-tracking API.


Provides an API that can track where an entity exists in the world.
In general; entities can only be in ONE plot at a time.


]]

local ptrack = {}


local plotEnts = umg.group("plot")




--[[
    QUESTION:
        Why arent these stored as a regular component?
    Answer:
        Because we dont want to imply strong ownership from ent -> plot.
        (Besides, these values are highly ephemeral.)
]]
local positionRef = {--[[
    [ent] = ppos
    (The ppos that was last seen for this entity)
]]}




local allGroup = umg.group()

allGroup:onRemoved(function(ent)
    if positionRef[ent] then
        positionRef[ent] = nil
    end
end)





local posTc = typecheck.assert("ppos")
function ptrack.set(ent, ppos)
    posTc(ppos)
    positionRef[ent] = ppos
    if ent.item then
        ptrack.set(ent.item, ppos)
    end
end



local function stillValid(ppos, ent)
    -- check if ppos is still valid for `ent`:
    -- (ppos will be valid if we can verify 
    --  that its still within the same slot.)
    if not ppos then
        return
    end
    local slotEnt = lp.posToSlot(ppos)
    if slotEnt == ent then
        return true
    end

    local itemEnt = lp.posToItem(ppos)
    if itemEnt == ent then
        return true
    end
end


function ptrack.get(ent)
    local ppos = positionRef[ent]
    -- check if the ppos ref is still valid:
    if stillValid(ppos, ent) then
        return ppos
    end
end



local event 
if server then
    event = "@tick"
else
    event = "@update"
end

umg.on(event, function(dt)
    for _, plotEnt in ipairs(plotEnts) do
        local plot = plotEnt.plot
        plot:foreachSlot(function(slotEnt, ppos)
            ptrack.set(slotEnt, ppos)
        end)
    end
end)


return ptrack
