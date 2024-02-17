



local constants = require("shared.constants")

local DEFAULT_DIMENSION = constants.DEFAULT_DIMENSION



local dimensions = {}



local overseeingDimensionGroup = umg.group("overseeingDimension")


local dimensionToOverseerEnt = {--[[
    [dimension] -> overseerEnt
]]}


local overseerEntToDimension = {--[[
    [overseerEnt] -> dimension
]]}




local function destroyDimension(dimension)
    assert(server, "?")
    local ent = dimensionToOverseerEnt[dimension]
    if ent then
        dimensionToOverseerEnt[dimension] = nil
        overseerEntToDimension[ent] = nil
        umg.call("spatial:dimensionDestroyed", dimension, ent)
        ent:delete()
    end
end


overseeingDimensionGroup:onAdded(function(ent)
    assert(ent.overseeingDimension, "wot wot?")
    local dim = ent.overseeingDimension
    dimensionToOverseerEnt[dim] = ent
    overseerEntToDimension[ent] = dim
    umg.call("spatial:dimensionCreated", dim, ent)
end)


overseeingDimensionGroup:onRemoved(function(ent)
    if server and ent.overseeingDimension then
        destroyDimension(ent.overseeingDimension)
    end
end)




local createDimTc = typecheck.assert("string", "table?")


function dimensions.createDimension(dimension, ent_or_nil)
    createDimTc(dimension, ent_or_nil)
    assert(server, "?")
    if dimensionToOverseerEnt[dimension] then
        error("Duplicate dimension created: " .. tostring(dimension))
    end

    -- create a dimension handler entity if one wasn't passed in
    local ent = ent_or_nil or server.entities.dimension_controller()
    ent.overseeingDimension = dimension

    dimensionToOverseerEnt[dimension] = ent
    return ent
end



local strTc = typecheck.assert("string")

function dimensions.destroyDimension(dimension)
    strTc(dimension)
    assert(server, "?")
    local overseer = spatial.getDimensionOverseer(dimension)
    if umg.exists(overseer) then
        overseer:delete()
    end
end



function dimensions.getDimensionOverseer(dim)
    -- gets the controller entity for a dimension.
    -- If the dimension doesn't exist, nil is returned.
    dim = dim or DEFAULT_DIMENSION
    return dimensionToOverseerEnt[dim]
end




function dimensions.getAllDimensions()
    local allDimensions = objects.Array()
    for _, dim in pairs(overseerEntToDimension) do
        allDimensions:add(dim)
    end
    return allDimensions
end




if server then
    -- create the default dimension on start-up
    umg.on("@createWorld", function()
        dimensions.createDimension(constants.DEFAULT_DIMENSION)
    end)
end


return dimensions
