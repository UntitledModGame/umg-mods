


-- TODO: map this properly with input mod
local DRAG_BUTTON = 1


local function getClickedOnChild(luiElem, button)
    for _, child in ipairs(luiElem:getChildren()) do
        if child:isClickedOnBy(button) then
            return child
        end
    end
end



local function dragElement(ent, luiElem, dx, dy)
    local child = getClickedOnChild(luiElem, DRAG_BUTTON)
    if not child then
        -- if child isn't clicked on; then drag.
        ent.uiRegion = ent.uiRegion:offset(dx, dy)
    end
end






umg.on("ui:elementMouseMoved", function(luiElem, mx, my, dx, dy, istouch)
    if luiElem:isClickedOnBy(DRAG_BUTTON) then
        local ent = luiElem:getEntity()
        if ent and ent.draggableUI and ent.uiRegion then
            dragElement(ent, luiElem, dx, dy)
        end
    end
end)


