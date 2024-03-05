


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

end









if client then

local clickEnts = umg.group("x", "y", "clickable")
local listener = input.InputListener({priority = 0})

-- pretty arbitrary size, lol
local clickEntPartition = spatial.DimensionPartition(200)

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

local function inRange(ent, dist)
    return (ent.clickableDistance or DEFAULT_CLICKABLE_DISTANCE) >= dist
end

local function clickEntityClient(ent, button, worldX, worldY, dimension)
    umg.call("clickables:entityClickedClient", ent, button, worldX, worldY, dimension)
end



local function click(self, controlEnum, button)
    local worldX, worldY = rendering.toWorldCoords(input.getPointerPosition())
    local dvec = rendering.getCamera():getDimensionVector()

    local bestDist = math.huge
    local bestEnt = nil

    for _, ent in clickEntPartition:iterator(dvec) do
        local x, y = ent.x, rendering.getDrawY(ent.y, ent.z)
        local dist = math.distance(x-worldX, y-worldY)
        if dist < bestDist then
            if inRange(ent, dist) then
                bestEnt = ent
                bestDist = dist
            end
        end
    end

    if bestEnt then
        local camera = rendering.getCamera()
        local dimension = camera:getDimension()
        client.send("clickables:entityClickedOnClient", bestEnt, button, worldX, worldY, dimension)
        clickEntityClient(bestEnt, button, worldX, worldY, dimension)
        self:claim(controlEnum)
    end
end



-- We pass in a number-enum for each click type;
-- This is *kinda* weird and hacky, but oh well :)
-- Gotta get this shit done yesterday.
local clickToNumber = {
    ["input:CLICK_1"] = 1,
    ["input:CLICK_2"] = 2,
    ["input:CLICK_3"] = 3
} 

local CLICKS = objects.Enum({
    "input:CLICK_1",
    "input:CLICK_2",
    "input:CLICK_3"
})

listener:onPress(CLICKS, function(self, controlEnum)
    local button = clickToNumber[controlEnum]
    click(self, controlEnum, button)
end)


end





components.project("onClick", "clickable")

umg.on("clickables:entityClicked", function(ent, clientId, button, worldX, worldY)
    if type(ent.onClick) == "function" then
        ent:onClick(clientId, button, worldX, worldY)
    end
end)



