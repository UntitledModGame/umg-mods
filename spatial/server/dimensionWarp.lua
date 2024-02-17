
--[[

Handles entities changing dimensions

]]

local constants = require("shared.constants")
local getDimension = require("shared.get_dimension")



local entToDimension = {--[[
    keeps track of what dimension entities are in.

    [ ent ] -> dimension
]]}



local DEFAULT_DIMENSION = constants.DEFAULT_DIMENSION


local dimensionGroup = umg.group("dimension")


local function moveDimensions(ent, oldDim, newDim)
    if dimensions.getOverseer(newDim) then
        -- then the dimension exists:
        entToDimension[ent] = newDim
        umg.call("spatial:entityMovedDimensions", ent, oldDim, newDim)
    else
        -- if the new dimension doesn't exist, set it to old dimension.
        ent.dimension = oldDim
        --[[
            TODO: Should we be emitting an event or something here..???
                To signal to other systems that an entity failed it's move..?
        ]]
    end
end



dimensionGroup:onAdded(function(ent)
    local dim = getDimension(ent)
    if dim ~= DEFAULT_DIMENSION then
        -- then this entity has moved dimensions!
        -- Since ent.dimension == nil implies that the entity is in DEFAULT dimension
        moveDimensions(ent, DEFAULT_DIMENSION, dim)
    else
        -- else, the ent STLL exists inside the default dimension
        entToDimension[ent] = DEFAULT_DIMENSION
    end
end)


dimensionGroup:onRemoved(function(ent)
    entToDimension[ent] = nil
end)




local function updateEnt(ent)
    --[[
        checks if the entity has changed dimensions.
        if so, emit a `entityMoved` callback.

        This allows any code on server-side to change dimensions on the fly,
        and have no weird issues.
    ]]
    local newDim = getDimension(ent)
    local oldDim = getDimension(entToDimension[ent])
    if oldDim ~= newDim then
        moveDimensions(ent, oldDim, newDim)
    end
end



if server then

umg.on("@tick", function()
    for i=1, #dimensionGroup do
        local ent = dimensionGroup[i]
        updateEnt(ent)
    end
end)

end

