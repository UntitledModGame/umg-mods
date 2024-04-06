

local Image = ui.Element("ui:Image")


function Image:init(args)
    self.image = args.image
end


local function renderImage(image, ...)
    if type(image) == "string" then
        -- then its the name of an asset!
        rendering.drawImage(image, ...)
    else
        -- else, its prolly just a love2d image
        umg.melt("todo: the offsets aren't done properly for this")
        love.graphics.draw(image, ...)
    end
end


local function getDimensions(image)
    return rendering.getImageSize(image)
end


function Image:onRender(x,y,w,h)
    local iw, ih = getDimensions(self.image)
    local region = ui.Region(x,y,w,h)
    local imgRegion = ui.Region(0,0,iw,ih)

    local padded = region:pad(0.05)
    local scale = imgRegion:getScaleToFit(padded)
    -- useful idiom when we want to scale image/text ^^^^

    local drawX, drawY
    drawX = padded.x + padded.w/2
    drawY = padded.y + padded.h/2
    love.graphics.setColor(1,1,1)
    renderImage(self.image,drawX,drawY,0,scale,scale)
end


function Image:setImage(x)
    self.image = x
end


function Image:scaleRegionToFit(region)
    --[[
        Scales `region` such that it fits the image perfectly.
    ]] 
    local iw, ih = self.image:getDimensions()
    local imgRegion = ui.Region(0,0,iw,ih)
    return imgRegion:scaleToFit(region)
end


return Image
