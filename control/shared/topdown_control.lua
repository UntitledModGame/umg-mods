
--[[

Handles top-down player control


]]
local topdownControl = {}




components.project("topdownControl", "controllable")




if client then
-- CLIENT-SIDE ONLY:

require("client.defaultControls")


local controllableGroup = umg.group("topdownControl", "x", "y")




local listener = input.InputListener()



local DELTA = 100
-- this number ^^^ is pretty arbitrary, we just need it to be sufficiently big

---@param self input.InputListener
local function updateMoveEnt(self, ent)
    ent.moveX = false
    ent.moveY = false

    if self:isDown("control:UP") then
        ent.moveY = ent.y - DELTA
    end
    if self:isDown("control:DOWN") then
        ent.moveY = ent.y + DELTA
    end
    if self:isDown("control:LEFT") then
        ent.moveX = ent.x - DELTA
    end
    if self:isDown("control:RIGHT") then
        ent.moveX = ent.x + DELTA
    end
end


listener:onUpdate(function(self, dt)
    for _, ent in ipairs(controllableGroup) do
        if sync.isClientControlling(ent) then
            updateMoveEnt(self, ent)
        end
    end
end)


topdownControl.listener = listener

end


return topdownControl
