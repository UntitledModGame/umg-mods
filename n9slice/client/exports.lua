---@meta
local n9p = require("lib.n9p")

local n9slice = {}
if false then _G.n9slice = n9slice end

---@type table<string, n9p.Instance>
local n9pObjects = setmetatable({}, {__mode = "v"})

-- Direct access to NPad93's 9-patch slice library.
-- If `n9slice` high-level function doesn't suit your needs, access the library functions directly here.
n9slice.n9p = n9p

local loadFromImageQuadTc = typecheck.assert("love:Texture|love:ImageData", "love:Quad", "table?")

---@class n9slice.settings
---@field public template? love.ImageData Use this template to scan stretchable areas.
---@field public stretchType? n9p.QuadDrawMode How to seamlessly resize stretchable areas? ("keep" is not a valid value)

---@param texture love.Texture|love.ImageData Texture atlas.
---@param quad love.Quad Subregion of the texture atlas to consider.
---@param settings n9slice.settings? Additional settings. See the `n9slice.settings` type for more information.
function n9slice.loadFromImageQuad(texture, quad, settings)
    loadFromImageQuadTc(texture, quad, settings)

    local x, y, w, h = quad:getViewport()
    local templating = false
    local imagedata = nil
    local tile = false

    if settings then
        if settings.template then
            imagedata = settings.template
            templating = true
        end

        tile = settings.stretchType == "repeat"
    end

    -- Do not alter subregion when using a template
    local subregion = nil
    if templating then
        local tw, th = imagedata:getDimensions()
        if (tw - 2) ~= w or (th - 2) ~= h then
            umg.melt("invalid template dimensions. Expected "..tw.."x"..th..", got "..w.."x"..h.." (note, template dimensions must be 2px larger than the quad)")
        end

        subregion = {x = x, y = y, w = w, h = h}
    else
        subregion = {x = x + 1, y = y + 1, w = w - 2, h = h - 2}
    end

    if not imagedata then
        if typecheck["love:Texture"](texture) then
            ---@cast texture love.Texture
            -- FIXME: This is slow. Is it cheaper to just re-load the ImageData?
            imagedata = love.graphics.readbackTexture(texture, nil, 1, x, y, w, h)
        else
            ---@cast texture love.ImageData
            imagedata = love.image.newImageData(w, h, texture:getFormat())
            imagedata:paste(texture, 0, 0, x, y, w, h)
        end
    end

    return n9p.loadFromImage(imagedata, {
        texture = texture,
        tile = tile,
        subregion = subregion
    })
end

---@param name string Name of the assets. Must be available in `client.assets.images`.
---@param settings n9slice.settings? Additional settings. See the `n9slice.settings` type for more information.
---@return n9p.Instance
function n9slice.loadFromAssets(name, settings)
    local n9pInstance = n9pObjects[name]

    if not n9pInstance then
        local quad = client.assets.images[name]
        if not quad then
            umg.melt("assets '"..name.."' does not exist")
        end

        n9pInstance = n9slice.loadFromImageQuad(client.atlas:getTexture(), quad, settings)
        n9pObjects[name] = n9pInstance
    end

    return n9pInstance
end

---@param path string Path to the 9-sliced image file.
---@param tile boolean? Tile the stretchable area instead of stretching it?
---@return n9p.Instance
function n9slice.loadFromPath(path, tile)
    local imageData = love.image.newImageData(path)
    return n9p.loadFromImage(imageData, {tile = not not tile})
end

umg.expose("n9slice")
return n9slice
