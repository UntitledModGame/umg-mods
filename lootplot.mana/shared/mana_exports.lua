
local interp = localization.newInterpolator


---@meta
lp.mana = {}


lp.mana.MANA_COLOR = objects.Color(77/255, 55/255, 175/255)
lp.mana.LIGHT_MANA_COLOR = objects.Color(160/255, 140/255, 250/255)

if client then
text.defineEffect("lootplot.mana:MANA_COLOR", function(_ctx, char)
    char:setColor(lp.mana.MANA_COLOR)
end)
text.defineEffect("lootplot.mana:LIGHT_MANA_COLOR", function(_ctx, char)
    char:setColor(lp.mana.LIGHT_MANA_COLOR)
end)
end



local entTc = typecheck.assert("entity")
function lp.mana.getManaCount(ent)
    entTc(ent)
    return ent.manaCount or 0
end

local entNumTc = typecheck.assert("entity", "number")

if server then

function lp.mana.addMana(ent, dx)
    entNumTc(ent, dx)
    assert(lp.isSlotEntity(ent), "Only slots can hold mana!")
    local manaCount = lp.mana.getManaCount(ent)
    lp.mana.setMana(ent, manaCount + dx)
end

function lp.mana.setMana(ent, x)
    entNumTc(ent, x)
    ent.manaCount = x
end


umg.on("lootplot:entityActivated", function(ent)
    if ent.manaCost then
        local ppos = lp.getPos(ent)
        local slot = ppos and lp.posToSlot(ppos)
        if slot then
            lp.mana.addMana(ent, -ent.manaCost)
        end
    end
end)

end -- if server



umg.answer("lootplot:canActivateEntity", function(ent)
    if ent.manaCost then
        local ppos = lp.getPos(ent)
        local slot = ppos and lp.posToSlot(ppos)
        if slot and lp.mana.getManaCount(ent) < ent.manaCost then
            -- You have no MANA!
            return false
        end
    end
    return true
end)




if client then

local ACTION_ORDER = 32

local MANA_COST_DESC = interp("{lootplot:BAD_COLOR}Costs {wavy}{lootplot.mana:LIGHT_MANA_COLOR}%{n} mana{/lootplot.mana:LIGHT_MANA_COLOR}{/wavy} to activate!")
local MANA_EARN_DESC = interp("{lootplot:INFO_COLOR}Gives {wavy}{lootplot.mana:LIGHT_MANA_COLOR}+%{n} mana{/lootplot.mana:LIGHT_MANA_COLOR}{/wavy} to slot!")

umg.on("lootplot:populateDescription", ACTION_ORDER, function(ent, arr)
    local manaCost = ent.manaCost
    if manaCost then
        if manaCost > 0 then
            arr:add(MANA_COST_DESC{
                n = manaCost,
            })
        elseif manaCost < 0 then
            -- if manaCost is negative, then the item EARNS mana instead.
            arr:add(MANA_EARN_DESC{
                n = -manaCost,
            })
        end
    end
end)



local INFO_ORDER = 60

local MANA_CHARGES = interp("Mana Count: {lootplot.mana:LIGHT_MANA_COLOR} %{n}")

umg.on("lootplot:populateDescription", INFO_ORDER, function(ent, arr)
    local manaCount = ent.manaCount
    if manaCount and manaCount > 0 then
        arr:add(MANA_CHARGES({
            n = math.floor(manaCount)
        }))
    end
end)



end -- if client
