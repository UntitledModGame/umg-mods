
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
"Gives {lootplot:POINTS_MULT_COLOR}+0.2 mult{/lootplot:POINTS_MULT_COLOR} for every target-item",
function(selfEnt, ppos, targetEnt)
    return true
end,
function (selfEnt, ppos, targetEnt)
    lp.addPointsMult(selfEnt, 0.3)
end)



defineCap("sticky_cap", "Sticky Cap",
"Gives {lootplot:POINTS_MULT_COLOR}+1 mult{/lootplot:POINTS_MULT_COLOR} for every {lootplot:STUCK_COLOR}STICKY{/lootplot:STUCK_COLOR} target-item",
function(selfEnt, ppos, targetEnt)
    return targetEnt.sticky or targetEnt.stuck
end,
function (selfEnt, ppos, targetEnt)
    lp.addPointsMult(selfEnt, 1)
end)



defineCap("white_cap", "White Cap",
"Earns {lootplot:POINTS_MULT_COLOR}+0.4 mult{/lootplot:POINTS_MULT_COLOR} for every {lootplot:INFO_COLOR}floating{/lootplot:INFO_COLOR} target-item",
function(selfEnt, ppos, targetEnt)
    return targetEnt.canItemFloat
end,
function (selfEnt, ppos, targetEnt)
    lp.addPointsMult(selfEnt, 0.4)
end, {
    canItemFloat = true
})

