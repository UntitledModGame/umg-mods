---@meta
local n9p = require("lib.n9p")

local n9slice = {}
if false then _G.n9slice = n9slice end

---@type table<string, n9p.Instance>
local n9pObjects = setmetatable({}, {__mode = "v"})

-- Direct access to NPad93's 9-patch slice library.
-- If `n9slice` high-level function doesn't suit your needs, access the library functions directly here.
n9slice.n9p = n9p

local loadFromImageQuadTc = typecheck.assert("love:Texture|love:ImageData", "love:Quad", "boolean?")

---@param texture love.Texture|love.ImageData Texture atlas.
---@param quad love.Quad Subregion of the texture atlas to consider.
---@param tile boolean? Tile the stretchable area instead of stretching it?
function n9slice.loadFromImageQuad(texture, quad, tile)
    loadFromImageQuadTc(texture, quad, tile)

    local x, y, w, h = quad:getViewport()
    local imagedata
    if typecheck["love:Texture"](texture) then
        ---@cast texture love.Texture
        -- FIXME: This is slow. Is it cheaper to just re-load the ImageData?
        imagedata = love.graphics.readbackTexture(texture, nil, 1, x, y, w, h)
    else
        ---@cast texture love.ImageData
        imagedata = love.image.newImageData(w, h, texture:getFormat())
        imagedata:paste(texture, 0, 0, x, y, w, h)
    end

    return n9p.loadFromImage(imagedata, {
        texture = texture,
        tile = not not tile,
        subregion = {x = x + 1, y = y + 1, w = w - 2, h = h - 2}
    })
end

---@param name string Name of the assets. Must be available in `client.assets.images`.
---@param tile boolean? Tile the stretchable area instead of stretching it?
---@return n9p.Instance
function n9slice.loadFromAssets(name, tile)
    local n9pInstance = n9pObjects[name]

    if not n9pInstance then
        local quad = client.assets.images[name]
        if not quad then
            umg.melt("assets '"..name.."' does not exist")
        end

        n9pInstance = n9slice.loadFromImageQuad(client.atlas:getTexture(), quad)
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
