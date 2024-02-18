
local getAllCategories = require("shared.get_all_categories")



local categoryMoveGroup = umg.group("x", "y", "vx", "vy", "category")
local categoryGroup = umg.group("x", "y", "category")




local categoryToChunk = {}


local function getCategoryPartition(category)
    if not categoryToChunk[category] then
        categoryToChunk[category] = spatial.DimensionPartition(chunks.getChunkSize())
    end
    return categoryToChunk[category]
end


umg.on("spatial:entityMovedDimension", function(ent, oldDim, newDim)
    if not ent.category then
        return
    end
    local categories = getAllCategories(ent)
    for _, cat in ipairs(categories) do
        getCategoryPartition(cat):entityMoved(ent, oldDim, newDim)
    end
end)



function addEntity(ent)
    local categories = getAllCategories(ent)
    for _, cat in ipairs(categories) do
        getCategoryPartition(cat):addEntity(ent)
    end
end


function removeEntity(ent)
    local categories = getAllCategories(ent)
    for _, cat in ipairs(categories) do
        getCategoryPartition(cat):removeEntity(ent)
    end
end



categoryGroup:onAdded(addEntity)

categoryGroup:onRemoved(removeEntity)




umg.on("@tick", function()
    for _, ent in ipairs(categoryMoveGroup) do
        local categories = getAllCategories(ent)
        for _, cat in ipairs(categories) do
            getCategoryPartition(cat):updateEntity(ent)
        end
    end
end)


local chunkedCategories = {
    categoryToChunk = categoryToChunk;
    addEntity = addEntity;
    removeEntity = removeEntity
}

return chunkedCategories

