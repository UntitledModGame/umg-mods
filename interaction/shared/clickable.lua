


sync.proxyEventToClient("interaction:entityClicked")




if server then

--[[
    TODO: For future, make it so that clients can only click ONCE per tick. 
    (Or else, server could potentially be downed)

    Maybe should be implemented by the sync mod or something tho?
]]
server.on("interaction:entityClickedOnClient", function(clientId, ent, button, worldX, worldY, dimension)
    if not (ent.clickable) then
        return
    end
    umg.call("interaction:entityClicked", ent, clientId, button, worldX, worldY)
end)

else -- clientside:

local clickEnts = umg.group("x", "y", "clickable")
local listener = input.Listener({priority = 0})

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


function listener:mousepressed(mx, my, button, istouch, presses)
    local worldX, worldY = rendering.toWorldCoords(mx, my)
    local dvec = rendering.getCamera():getDimensionVector()

    local bestDist = math.huge
    local bestEnt = nil

    for _, ent in clickEntPartition:iterator(dvec) do
        local x, y = ent.x, rendering.getDrawY(ent.y, ent.z)
        local dist = math.distance(x-worldX, y-worldY)
        if dist < bestDist then
            if rendering.isHovered(ent) then
                bestEnt = ent
                bestDist = dist
            end
        end
    end

    if bestEnt then
        local camera = rendering.getCamera()
        local dimension = camera:getDimension()
        client.send("interaction:entityClickedOnClient", bestEnt, button, worldX, worldY, dimension)
        self:lockMouseButton(button)
    end
end

end





components.project("onClick", "clickable")

umg.on("interaction:entityClicked", function(ent, clientId, button, worldX, worldY)
    if type(ent.onClick) == "function" then
        ent:onClick(clientId, button, worldX, worldY)
    end
end)

