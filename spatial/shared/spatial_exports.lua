


local spatial = {}


spatial.DimensionPartition = require("shared.dimensions.DimensionPartition")



local getDimension = require("shared.dimensions.getDimension")
local api = require("shared.dimensions.dimensions")



spatial.getDimension = getDimension


spatial.getDimensionOverseer = api.getDimensionOverseer

spatial.getAllDimensions = api.getAllDimensions



local type = type
local function exists(dim)
    if type(dim) ~= "string" then
        return false, "expected dimension"
    end
    if dim == "overworld" then
        -- its fine
        return true
    end
    if not spatial.getDimensionOverseer(dim) then
        return false, "expected dimension"
    end
    return true
end

typecheck.addType("dimension", exists)


spatial.DimensionVector = require("shared.dimensions.DimensionVector")

spatial.DimensionPartition = require("shared.dimensions.DimensionPartition")
spatial.DimensionStructure = require("shared.dimensions.DimensionStructure")


--[[
    generates a unique dimension name based off of `name`.
    For example:
    generateUniqueDimension("house") --> "house_238934985458"

    returned dimension is guaranteed to be unique.
]]
local MAX_ITER = 10000
local MAX_NUMBER = 2^30
local GEN_SEP = "_"

--[[
    TODO: 
    There's a *bit* of an issue with this...
    What happens if we save a dimension to disk using some mod, and then
    we generate a new dimension that chooses a dimension-id
    as the one that has been saved to disk...???
    Uh oh!
]]
function spatial.generateUniqueDimension(name)
    if not spatial.getDimensionOverseer(name) then
        -- if there are no dimensions called `name`, then we can just use name
        return name
    end

    -- else, generate a new one by appending big random number
    local i = 0
    while i < MAX_ITER do
        local num = love.math.random(MAX_NUMBER)
        local dim = name .. GEN_SEP .. tostring(num)
        if not spatial.getDimensionOverseer(dim) then
            return dim
        end
    end
end


if server then
--[[
    creating / destroying is only available on server
]]
spatial.createDimension = api.createDimension
spatial.destroyDimension = api.destroyDimension

end



local DEFAULT_DIMENSION = require("shared.constants").DEFAULT_DIMENSION

function spatial.getDefaultDimension()
    return DEFAULT_DIMENSION
end






umg.expose("spatial", spatial)

