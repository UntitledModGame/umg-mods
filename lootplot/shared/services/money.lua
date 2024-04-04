
--[[

Money service

]]

local context = require("shared.services.lootplot")


local money = {}

if server then

--[[
`fromEnt` is the entity that applied the money modification.
(So for example, it could be a slot, or an item.)
]]
local function modifyMoney(fromEnt, x)
    local multiplier = umg.ask("lootplot:getMoneyMultiplier", fromEnt)
    local val = x*multiplier
    if val > 0 then
        umg.call("lootplot:moneyAdded", fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:moneySubtracted", fromEnt, val)
    end
    money.setMoney(fromEnt, val)
end

local modifyTc = typecheck.assert("entity", "number")

function money.addMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyMoney(fromEnt, x)
end

function money.subtractMoney(fromEnt, x)
    modifyTc(fromEnt, x)
    modifyMoney(fromEnt, -x)
end

function money.setMoney(ent, val)
    context.setMoney(ent, val)
    umg.call("lootplot:setMoney", ent, val)
end

end



function money.getMoney(ent)
    return context.getMoney(ent)
end


return money

