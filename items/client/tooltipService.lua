

local tooltipService = {}


local function getItemDescription(itemEnt)
    --[[
        TODO: add proper stuff here
    ]]
    return itemEnt.itemName or itemEnt:type()
end



function tooltipService.startHoverOfSlot(slotElement)

end


function tooltipService.endHoverOfSlot(slotElement)

end



umg.on("rendering:drawUI", function()

end)



return tooltipService

