
--[[

CAPS:
Work well with items with certain properties.
==================================


red-cap:
Give +0.2 mult for every target-item that generates mult

gold-cap:
Earn $1 for every target-item that earns (or costs) money

blue-cap:
Earns 15 points for every target-item that generates points

]]


local loc=localization.localize


---@param id string
---@param name string
---@param desc string
---@param filter fun(selfEnt: Entity, ppos: lootplot.PPos, targetEnt: Entity): boolean
---@param activate fun(selfEnt: Entity, ppos: lootplot.PPos, targetEnt: Entity)
---@param etype table?
local function defineCap(id, name, desc, filter, activate, etype)
    etype=etype or {}
    etype.name = loc(name)
    etype.image=id

    etype.triggers = {"PULSE"}

    etype.activateDescription = loc(desc)

    etype.basePrice = etype.basePrice
    etype.baseMaxActivations = 5

    etype.rarity = etype.rarity or lp.rarities.RARE

    etype.shape = etype.shape or lp.targets.KingShape(1)

    etype.target = etype.target or {
        type = "ITEM",
        activate = activate,
        filter = filter
    }

    lp.defineItem("lootplot.s0.content:"..id, etype)
end


defineCap("blue_cap", "Blue Cap",
"Earns {lootplot:POINTS_COLOR}15 points{/lootplot:POINTS_COLOR} for every target-item that generates points",
function(selfEnt, ppos, targetEnt)
    return targetEnt.pointsGenerated and targetEnt.pointsGenerated > 0
end,
function (selfEnt, ppos, targetEnt)
    lp.addPoints(selfEnt, 15)
end)


defineCap("golden_cap", "Golden Cap",
"Earns {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every target-item that earns money",
function(selfEnt, ppos, targetEnt)
    return targetEnt.moneyGenerated and targetEnt.moneyGenerated > 0
end,
function (selfEnt, ppos, targetEnt)
    lp.addMoney(selfEnt, 1)
end)


defineCap("red_cap", "Red Cap",
"Adds a {lootplot:POINTS_MULT_COLOR}0.1 multiplier{/lootplot:POINTS_MULT_COLOR} for every target-item that gives multiplier",
function(selfEnt, ppos, targetEnt)
    return targetEnt.multGenerated and targetEnt.multGenerated > 1
end,
function (selfEnt, ppos, targetEnt)
    lp.addPointsMult(selfEnt, 0.1)
end)
