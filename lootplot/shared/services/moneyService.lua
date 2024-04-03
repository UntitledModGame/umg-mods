
--[[

Money service

]]

local money = {}

if server then

local modifyTc = typecheck.assert("entity", "entity", "number")
--[[

Question:
What is "fromEnt"...?

`fromEnt` is the entity that applied the money modification.
(So for example, it could be a slot, or an item.)

]]

local function modifyMoney(ent, fromEnt, x)
    local multiplier = umg.ask("lootplot:getMoneyMultiplier", fromEnt, ent)
    local val = x*multiplier
    ent.money = ent.money + val
    if val > 0 then
        umg.call("lootplot:moneyAdded", ent, fromEnt, val)
    elseif val < 0 then
        umg.call("lootplot:moneySubtracted", ent, fromEnt, val)
    end
end

function money.addMoney(ent, fromEnt, x)
    modifyTc(ent, fromEnt, x)
    modifyMoney(ent, fromEnt, x)
end

function money.subtractMoney(ent, fromEnt, x)
    modifyTc(ent, fromEnt, x)
    modifyMoney(ent, fromEnt, -x)
end

function money.setMoney(ent, val)
    ent.money = val
end

end



function money.getMoney(ent)
    return ent.money
end


return money

