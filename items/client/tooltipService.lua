

local tooltipService = {}


local currentTooltipSlot = nil



function tooltipService.startHover(slotElement)
    currentTooltipSlot = slotElement
end


function tooltipService.endHover(slotElement)
    if slotElement == currentTooltipSlot then
        currentTooltipSlot = nil
    end
end




local function check(slotElem)
    if not slotElem:isHovered() then
        return false
    end
    local ent = slotElem:getParentEntity()
    if not umg.exists(ent) then
        return false
    end
    if not ui.basics.SCENE:isOpen(ent) then
        return false
    end
    return true
end




local function getItemName(itemEnt)
    --[[
        TODO: add proper stuff here
    ]]
    return itemEnt.itemName or itemEnt:type()
end



local function getItemTooltip(itemEnt)
    local array = objects.Array()
    if itemEnt.itemDescription then
        array:add(itemEnt.itemDescription)
    end
    
    umg.call("items:collectItemTooltips", itemEnt, array)
    return array
end



local lg = love.graphics


local X_SHIFT = 26
local TEXTBOX_PADDING = 14 -- padding in BOTH directions

local function getTextSize(txt, font)
    local w = font:getWidth(txt) + TEXTBOX_PADDING * 2
    local h = font:getHeight(txt) + TEXTBOX_PADDING * 2
    return w,h
end



local function drawTooltipBackground(x,y,w,h)
    -- setcolors here...?
    lg.setColor(0.8,0.8,0.8)
    lg.rectangle("fill", x,y,w,h)
    lg.setColor(0,0,0)
    lg.rectangle("line", x,y,w,h)
end


local function drawTooltipText(txt, x, y)
    --[[
        TODO:
        this should eventually use some text-rendering API.
        text mod or somethin???
    ]]
    x,y = math.floor(x), math.floor(y)
    lg.print(txt, x, y)
end


local function drawTooltip(itemEnt)
    local mx,my = input.getPointerPosition()
    local font = lg.getFont()

    local name = getItemName(itemEnt)
    -- starting size 
    local width, height = getTextSize(name, font)
    local drawX, drawY = mx + X_SHIFT, my

    local descriptions = getItemTooltip(itemEnt)
    for _, txt in ipairs(descriptions) do
        local w,h = getTextSize(txt, font)
        width = math.max(width, w)
        height = height + h
    end

    drawTooltipBackground(drawX, drawY, width, height)

    lg.setColor(0,0,0)
    drawTooltipText(name, drawX + TEXTBOX_PADDING, drawY + TEXTBOX_PADDING)
    local _,nameH = getTextSize(name, font)
    local currDrawY = drawY + nameH
    for _, txt in ipairs(descriptions) do
        local _,h = getTextSize(txt, font)
        drawTooltipText(txt, drawX + TEXTBOX_PADDING, currDrawY + TEXTBOX_PADDING)
        currDrawY = currDrawY + h
    end
    umg.call("items:drawTooltip", itemEnt, drawX, drawY)
end



-- we need to render AFTER the ui.
local ORDER = 2

umg.on("rendering:drawUI", ORDER, function()
    if currentTooltipSlot and check(currentTooltipSlot) then
        local itemEnt = currentTooltipSlot:getItem()
        if itemEnt then
            drawTooltip(itemEnt)
        end
    else
        currentTooltipSlot = nil
    end
end)



return tooltipService

