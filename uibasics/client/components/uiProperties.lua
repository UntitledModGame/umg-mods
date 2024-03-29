



--[[
===========================
    Clamped:
===========================
]]
local function getClampedRegion(ent, sceneRegion)
    local region = ent.uiRegion
    return region
        :clampInside(sceneRegion)
end


local clampedUIGroup = umg.group("uiProperties", "ui")

umg.on("@update", function()
    local sceneRegion = uiBasics.getSceneRegion()
    for _, ent in ipairs(clampedUIGroup) do
        if ui.isOpen(ent) then
            ent.uiRegion = getClampedRegion(ent, sceneRegion)
        end
    end
end)





--[[
===========================
    Draggable:
===========================
]]
local function getClickedOnChild(luiElem)
    for _, child in ipairs(luiElem:getChildren()) do
        if child:isClicked() then
            return child
        end
    end
end

local function dragElement(ent, luiElem, dx, dy)
    local child = getClickedOnChild(luiElem)
    if not child then
        -- if child isn't clicked on; then drag.
        ent.uiRegion = ent.uiRegion:offset(dx, dy)
    end
end

umg.on("ui:elementPointerMoved", function(luiElem, dx, dy)
    if luiElem:isClicked() then
        local ent = luiElem:getEntity()
        if ent and ent.draggableUI and ent.uiRegion then
            dragElement(ent, luiElem, dx, dy)
        end
    end
end)





--[[
===========================
    Toggleable:
===========================
]]