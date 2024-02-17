


local RANGE_ACCEPTANCE = 80




sync.proxyEventToClient("control:entityClicked")


local getDimension = spatial.getDimension


local function isInRange(ent, worldX, worldY, dimension)
    local dist = math.distance(ent.x - worldX, ent.y - worldY)
    return dist < RANGE_ACCEPTANCE and dimension == getDimension(ent)
end




if server then

server.on("control:entityClicked", function(clientId, ent, button, worldX, worldY, dimension)
    if not (ent.clickable) then
        return
    end
    if button ~= 1 and button ~= 2 then
        return
    end
    if not isInRange(ent, worldX, worldY, dimension) then
        return
    end

    umg.call("control:entityClicked", ent, clientId, button, worldX, worldY)
end)

else -- clientside:

local clickEnts = umg.group("x", "y", "clickable")
local listener = input.Listener({priority = 0})

function listener:mousepressed(mx, my, button, istouch, presses)
    -- TODO: This is kinda trash.
    -- this needs to be spatial partitioned probably.
    local worldX, worldY = rendering.toWorldCoords(mx, my)

    local bestDist = math.huge
    local bestEnt = nil

    for _, ent in ipairs(clickEnts) do
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
        client.send("control:entityClicked", bestEnt, button, worldX, worldY, dimension)
        self:lockMouseButton(button)
    end
end

end





components.project("onClick", "clickable")

umg.on("control:entityClicked", function(ent, clientId, button, worldX, worldY)
    if type(ent.onClick) == "function" then
        ent:onClick(clientId, button, worldX, worldY)
    end
end)

