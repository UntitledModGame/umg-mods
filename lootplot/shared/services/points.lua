--[[

Points service

]]

local points = {}

if server then


--[[
`fromEnt` is the entity that applied the point modification.
(IE a slot, or an item.)

Depending on the gamemode; this will be handled in different ways.
]]
local function modifyPoints(fromEnt, x)
    local multiplier = umg.ask("lootplot:getPointMultiplier", fromEnt, x)
    local val = x*multiplier
    if val > 0 then
        umg.call("lootplot:moneyAdded", fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:moneySubtracted", fromEnt, val)
    end
    points.setPoints(fromEnt, val)
end

local modifyTc = typecheck.assert("entity", "number")

function points.addPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyPoints(fromEnt, x)
end

function points.subtractPoints(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyPoints(fromEnt, -x)
end

function points.setPoints(fromEnt, val)
    umg.call("lootplot:setPoints", fromEnt, val)
end

end



function points.getMoney(ent)
    return ent.money
end


return points

