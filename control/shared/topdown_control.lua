
--[[

Handles top-down player control


]]





components.project("topdownControl", "controllable")




if client then
-- CLIENT-SIDE ONLY:


local controllableGroup = umg.group("topdownControl", "x", "y")




local listener = input.InputListener({priority = -1})





local DELTA = 100
-- this number ^^^ is pretty arbitrary, we just need it to be sufficiently big


local function updateMoveEnt(self, ent)
    ent.moveX = false
    ent.moveY = false

    if self:isDown(input.UP) then
        ent.moveY = ent.y - DELTA
    end
    if self:isDown(input.DOWN) then
        ent.moveY = ent.y + DELTA
    end
    if self:isDown(input.LEFT) then
        ent.moveX = ent.x - DELTA
    end
    if self:isDown(input.RIGHT) then
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




end


