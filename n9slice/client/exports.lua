---@meta
local n9p = require("lib.n9p")

local n9slice = {}
if false then _G.n9slice = n9slice end


-- Direct access to NPad93's 9-patch slice library.
-- If `n9slice` high-level function doesn't suit your needs, access the library functions directly here.
n9slice.n9p = n9p


---@alias n9slice.StretchType
--- Scale to fit.
---| "stretch"
--- Tile to fit (don't scale).
---| "repeat"



---@class n9slice.args
---@field public image love.Texture
---@field public cornerWidth number
---@field public cornerHeight number
---@field public quad? love.Quad
---@field public stretchType? n9slice.StretchType


---@param args n9slice.args
function n9slice.new(args)
    local shouldTile = args.stretchType == "repeat"
    local tW, tH = args.image:getPixelDimensions()

    local subX, subY, subW, subH = 0, 0, tW, tH
    if args.quad then
        subX, subY, subW, subH = args.quad:getViewport()
    end

    local cW, cH = args.cornerWidth, args.cornerHeight

    local obj = n9slice.n9p.newBuilder()
        :addHorizontalSlice(cW, subW - cW, shouldTile)
        :addVerticalSlice(cH, subH - cH, shouldTile)
        :setHorizontalPadding(cW, subW - cW)
        :setVerticalPadding(cH, subH - cH)
        :build(tW, tH, subX, subY, subW, subH)

    obj:setTexture(args.image)
    return obj
end


local loadFromImageQuadTc = typecheck.assert("love:Texture|love:ImageData", "love:Quad?", "table?")

---@param texture love.Texture|love.ImageData Texture atlas.
---@param quad love.Quad|nil Subregion of the texture atlas to consider or `nil` for the whole texture atlas.
---@param settings n9slice.settings? Additional settings. See the `n9slice.settings` type for more information.
function n9slice.loadFromImageQuad(texture, quad, settings)
    loadFromImageQuadTc(texture, quad, settings)

    local x, y, w, h = 0, 0, texture:getDimensions()
    if quad then
        x, y, w, h = quad:getViewport()
    end

    local templating = false
    local imagedata = nil
    local tile = false

    settings = settings or {}
    if settings.template then
        imagedata = settings.template
        templating = true
    end

    tile = settings.stretchType == "repeat"

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
        if typecheck.isType(texture, "love:Texture") then
            ---@cast texture love.Texture
            -- FIXME: This is slow. Is it cheaper to just re-load the ImageData?
            imagedata = love.graphics.readbackTexture(texture, nil, 1, x, y, w, h)
        else
            ---@cast texture love.ImageData
            imagedata = love.image.newImageData(w, h, texture:getFormat())
            imagedata:paste(texture, 0, 0, x, y, w, h)
        end
    end

    local obj

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

umg.expose("n9slice", n9slice)
return n9slice
