



--[[
===========================
    Clamped:
===========================
]]
local function getClampedRegion(ent, sceneRegion)
    local region = ent.ui.region
    return region
        :clampInside(sceneRegion)
end


local clampedUIGroup = umg.group("uiProperties", "ui")

umg.on("@update", function()
    local sceneRegion = ui.basics.getSceneRegion()
    for _, ent in ipairs(clampedUIGroup) do
        local uiProperties = ent.uiProperties
        if uiProperties.clamped and ui.basics.isOpen(ent) then
            ent.ui.region = getClampedRegion(ent, sceneRegion)
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
        ent.ui.region = ent.ui.region:offset(dx, dy)
    end
end

umg.on("ui:elementPointerMoved", function(luiElem, x,y, dx,dy)
    if luiElem:isClicked() then
        local ent = luiElem:getEntity()
        if ent and ent.uiProperties and ent.uiProperties.draggable then
            dragElement(ent, luiElem, dx, dy)
        end
    end
end)





--[[
===========================
    Toggleable:
===========================
]]