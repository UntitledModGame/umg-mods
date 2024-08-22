---@meta
local n9p = require("lib.n9p")

local n9slice = {}
if false then _G.n9slice = n9slice end


--[[
In future:
if we really need to, we can re-expose n9p.
Right now, API is too complex tho.
]]
-- n9slice.n9p = n9p


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
    local tW, tH = args.image:getDimensions()

    local subX, subY, subW, subH = 0, 0, tW, tH
    if args.quad then
        subX, subY, subW, subH = args.quad:getViewport()
    end

    local startX = subX + args.cornerWidth
    local startY = subY + args.cornerHeight
    local endX = subX + subW - args.cornerWidth
    local endY = subY + subH - args.cornerHeight

    local obj = n9p.newBuilder()
        :addHorizontalSlice(startX, endX, shouldTile)
        :addVerticalSlice(startY, endY, shouldTile)
        :setHorizontalPadding(startX, endX)
        :setVerticalPadding(startY, endY)
        :build(tW, tH, subX, subY, subW, subH)

    obj:setTexture(args.image)
    return obj
end



umg.expose("n9slice", n9slice)
return n9slice
