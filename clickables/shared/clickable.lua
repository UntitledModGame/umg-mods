local clickables = {}


sync.proxyEventToClient("clickables:entityClicked")




if server then

--[[
    TODO: For future, make it so that clients can only click ONCE per tick. 
    (Or else, server could potentially be downed)

    Maybe should be implemented by the sync mod or something tho?
]]
server.on("clickables:entityClickedOnClient", function(clientId, ent, button, worldX, worldY, dimension)
    if not (ent.clickable) then
        return
    end
    umg.call("clickables:entityClicked", ent, clientId, button, worldX, worldY)
end)

else -- client

local clickEnts = umg.group("x", "y", "clickable")
local listener = input.InputListener()

clickables.listener = listener



-- pretty arbitrary size, lol
local clickEntPartition = spatial.DimensionPartition(100)

clickEnts:onAdded(function(ent)
    clickEntPartition:addEntity(ent)
end)
clickEnts:onRemoved(function(ent)
    clickEntPartition:removeEntity(ent)
end)

umg.on("@tick", function()
    for _, ent in ipairs(clickEnts) do
        clickEntPartition:updateEntity(ent)
    end
end)


local DEFAULT_CLICKABLE_DISTANCE = 30

local function inRange(ent, x, y)
    if hitboxes.hasHitbox(ent) then
        return hitboxes.isHit(ent, x, y)
    else
        return math.sqrt((ent.x - x) ^ 2 + (ent.y - y) ^ 2) <= DEFAULT_CLICKABLE_DISTANCE
    end
end

local function clickEntityClient(ent, button, worldX, worldY, dimension)
    --[[
        question:
        Why do we need this, when
    ]]
    umg.call("clickables:entityClickedClient", ent, button, worldX, worldY, dimension)
end



local function click(self, controlEnum, button)
    local currentCamera = camera.get()
    local worldX, worldY = currentCamera:toWorldCoords(input.getPointerPosition())
    local dvec = {
        x = worldX,
        y = worldY,
        dimension = currentCamera:getDimension()
    }

    local bestDist = math.huge
    local bestEnt = nil

    for _, ent in clickEntPartition:iterator(dvec) do
        local x, y = ent.x, rendering.getDrawY(ent.y, ent.z)
        local dist = math.distance(x-worldX, y-worldY)
        if dist < bestDist and inRange(ent, worldX, worldY) then
            bestEnt = ent
            bestDist = dist
        end
    end

    if bestEnt then
        client.send("clickables:entityClickedOnClient", bestEnt, button, worldX, worldY, dvec.dimension)
        clickEntityClient(bestEnt, button, worldX, worldY, dvec.dimension)
        self:claim(controlEnum)
    end
end



-- We pass in a number-enum for each click type;
-- This is *kinda* weird and hacky, but oh well :)
-- Gotta get this shit done yesterday.
local clickToNumber = {
    ["input:CLICK_PRIMARY"] = 1,
    ["input:CLICK_SECONDARY"] = 2,
} 

local CLICKS = {
    "input:CLICK_PRIMARY",
    "input:CLICK_SECONDARY",
}

listener:onPressed(CLICKS, function(self, controlEnum)
    local button = clickToNumber[controlEnum]
    click(self, controlEnum, button)
end)


end -- if server





components.project("onClick", "clickable")

umg.on("clickables:entityClicked", function(ent, clientId, button, worldX, worldY)
    if type(ent.onClick) == "function" then
        ent:onClick(clientId, button, worldX, worldY)
    end
end)



return clickables
