
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





local setTc = typecheck.assert("voidEntity", "ppos")
function ptrack.set(ent, ppos)
    setTc(ent, ppos)
    positionRef[ent] = ppos
end


function ptrack.clear(ent)
    positionRef[ent] = nil
end



local layerGroup = umg.group("layer")
layerGroup:onRemoved(ptrack.clear)



local function stillValid(ppos, ent)
    -- check if ppos is still valid for `ent`:
    -- (ppos will be valid if we can verify 
    --  that its still within the same slot.)
    if not ppos then
        return false
    end
    if not umg.exists(ent) then
        return false
    end

    local plot = ppos:getPlot()
    local x,y = plot:indexToCoords(ppos.slot)
    if plot:get(ent.layer, x,y) == ent then
        return true
    end
    return false
end


function ptrack.get(ent)
    local ppos = positionRef[ent]
    -- check if the ppos ref is still valid:
    if stillValid(ppos, ent) then
        return ppos
    end
end



local updEvent 
if server then
    updEvent = "@tick"
else
    updEvent = "@update"
end



local function setPPos(ent, ppos, _layer)
    --[[
    inlined version of ptrack.set, because this code is very hot.
    (YES, we benchmarked this; its not premature optimization)
    ]]
    positionRef[ent] = ppos
end

local function updatePlot(plotEnt)
    local plot = plotEnt.plot
    plot:foreachLayerEntry(setPPos)
end

umg.on(updEvent, function(dt)
    for _, plotEnt in ipairs(plotEnts) do
        updatePlot(plotEnt)
    end
end)


return ptrack
