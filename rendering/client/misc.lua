

--[[

A bunch of useful functions that don't really belong elsewhere.

]]


local entityProperties = require("client.helper.entity_properties")

local constants = require("client.constants")


local floor = math.floor

-- gets the "screen" Y from y and z position.
local function getDrawY(y, z)
    return y - (z or 0)/2
end


local function getDrawDepth(y,z)
    return floor(y + (z or 0))
end


local function getEntityDrawDepth(ent)
    local depth = ent.drawDepth or 0
    return getDrawDepth((ent.y or 0) + depth, ent.z)
end




local DEFAULT_LEIGHWAY = constants.SCREEN_LEIGHWAY
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()



local DEFAULT_DIMENSION = spatial.getDefaultDimension()

local function isOnScreen(dVec, leighway)
    -- Returns true if a dimensionVector is on screen
    -- false otherwise.
    local x, y, dimension = dVec.x, getDrawY(dVec.y, dVec.z), dVec.dimension
    local w,h = screenWidth, screenHeight
    local camera = camera.get()
    if camera:getDimension() ~= (dimension or DEFAULT_DIMENSION) then
        return false -- camera is looking at a different dimension
    end
    leighway = leighway or DEFAULT_LEIGHWAY
    w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
    x, y = camera:toCameraCoords(x, y)

    return -leighway <= x and x <= w + leighway
            and -leighway <= y and y <= h + leighway
end




local getOpacity, getColor = entityProperties.getOpacity, entityProperties.getColor
local isHidden = entityProperties.isHidden

local setColor = love.graphics.setColor



local function setColorOfEnt(ent)
    local r,g,b = getColor(ent)
    local a = getOpacity(ent)
    setColor(r,g,b,a)
end



local drawEntityTc = typecheck.assert("entity", "number", "number")
local function drawEntity(ent, x,y, rot, sx,sy, kx,ky)
    drawEntityTc(ent, x,y)
    if not isHidden(ent) then
        setColorOfEnt(ent)
        rot = rot or 0
        sx,sy = sx or 1, sy or 1
        umg.call("rendering:drawEntity", ent, x,y, rot, sx,sy, kx,ky)
        if ent.onDraw then
            ent:onDraw(x,y, rot, sx,sy, kx,ky)
        end
    end
end






return {
    getDrawY = getDrawY,
    getDrawDepth = getDrawDepth,
    getEntityDrawDepth = getEntityDrawDepth,

    isOnScreen = isOnScreen,
    drawEntity = drawEntity
}
