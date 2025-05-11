

local helper = {}


local function renderImage(image, ...)
    if type(image) == "string" or typecheck.isType(image, "love:Quad") then
        -- then its the name of an asset!
        rendering.drawImage(image, ...)
    else
        -- else, its prolly just a love2d image
        -- umg.melt("todo: the offsets aren't done properly for this")
        love.graphics.draw(image, ...)
    end
end


---@param image string|love.Quad|love.Texture
---@return number,number
local function getDimensions(image)
    if typecheck.isType(image, "love:Texture") then
        ---@cast image love.Texture
        return image:getDimensions()
    else
        ---@cast image -love.Texture
        return rendering.getImageSize(image)
    end
end


---@param image string|love.Quad|love.Texture
---@param x number
---@param y number
---@param w number
---@param h number
---@param rot number
function helper.drawImageInBox(image, x,y,w,h, rot)
    local iw, ih = getDimensions(image)
    local region = layout.Region(x,y,w,h)
    local imgRegion = layout.Region(0,0,iw,ih)

    local padded = region:padRatio(0.05)
    local scale = imgRegion:getScaleToFit(padded)
    -- useful idiom when we want to scale image/text ^^^^

    rot=rot or 0
    local drawX, drawY
    drawX = padded.x + padded.w/2
    drawY = padded.y + padded.h/2
    renderImage(image,drawX,drawY,rot,scale,scale)
end


return helper
