
local getAllCategories = require("shared.get_all_categories")


local categoryMap = setmetatable({}, {
    __index = function(t,k)
        t[k] = objects.Set()
        return t[k]
    end
})


local categoryGroup = umg.view("x", "y", "category")

function addEntity(ent)
    local allCategories = getAllCategories(ent)
    for _, category in ipairs(allCategories) do
        categoryMap[category]:add(ent)
        if type(category) ~= "string" then
            umg.melt(".category value must be string or list of strings: " .. tostring(ent))
        end
    end
end


function removeEntity(ent)
    local allCategories = getAllCategories(ent)
    for _, category in ipairs(allCategories) do
        categoryMap[category]:remove(ent)
    end
end


categoryGroup:onAdded(addEntity)

categoryGroup:onRemoved(removeEntity)



local regularCategories = {
    categoryMap = categoryMap;
    addEntity = addEntity;
    removeEntity = removeEntity
}


return regularCategories
