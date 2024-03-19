
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
        ptrack.set(ent, ppos)
    end
end



local function stillValid(slotEnt, ent)
    -- check if ppos is still valid:
    if slotEnt == ent then
        return true
    end
    if umg.exists(slotEnt.item) then
        return stillValid(slotEnt.item, ent)
    end
end

function ptrack.get(ent)
    local ppos = positionRef[ent]
    local e = ppos.plot:getSlot(ent)
    -- check if the ppos ref is still valid:
    if stillValid(e, ent) then
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
        plot:foreach(function(slotEnt, slot)
            local ppos = {
                plot = plot,
                slot = slot
            }
            ptrack.set(slotEnt, ppos)
        end)
    end
end)


return ptrack
