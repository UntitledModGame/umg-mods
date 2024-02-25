

local tooltipService = {}


local currentTooltipSlot = nil


local function getItemDescription(itemEnt)
    --[[
        TODO: add proper stuff here
    ]]
    return itemEnt.itemName or itemEnt:type()
end



function tooltipService.startHover(slotElement)

end


function tooltipService.endHover(slotElement)

end




local function check(slotElem)
    if not slotElem:isHovered() then
        return false
    end
    if not umg.exists(slotElem:getEntity()) then
        return false
    end
    return true
end



local lg = love.graphics

local function renderTooltip(slotElement)
    local mx,my = love.mouse.getPosition()
    lg.print("hi", mx, my)
end



-- we need to render AFTER the ui.
local order = 2


umg.on("rendering:drawUI", order, function()
    if currentTooltipSlot and check(currentTooltipSlot) then
        renderTooltip(currentTooltipSlot)
    else
        currentTooltipSlot = nil
    end
end)



return tooltipService

