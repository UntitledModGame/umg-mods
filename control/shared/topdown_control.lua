
--[[

Handles top-down player control


]]





components.project("topdownControl", "controllable")

components.project("topdownControl", "")



if client then
-- CLIENT-SIDE ONLY:


local controllableGroup = umg.group("topdownControl", "x", "y")




local listener = input.Listener({priority = -1})





local DELTA = 100
-- this number ^^^ is pretty arbitrary, we just need it to be sufficiently big


local function updateMoveEnt(ent)
    ent.moveX = false
    ent.moveY = false

    if listener:isControlDown(input.UP) then
        ent.moveY = ent.y - DELTA
    end
    if listener:isControlDown(input.DOWN) then
        ent.moveY = ent.y + DELTA
    end
    if listener:isControlDown(input.LEFT) then
        ent.moveX = ent.x - DELTA
    end
    if listener:isControlDown(input.RIGHT) then
        ent.moveX = ent.x + DELTA
    end
end



function listener:update()
    for _, ent in ipairs(controllableGroup) do
        if sync.isClientControlling(ent) then
            updateMoveEnt(ent)
        end
    end
end




end


