
--[[


=====================
BOOTS:
=====================

Boots items are related to slots, somehow.
EG: 
Iron-boots: Give +1 points to slot

]]




local loc = localization.localize
local interp = localization.newInterpolator

local consts = require("shared.constants")


local function defBoots(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.baseMaxActivations = 4

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



defBoots("iron_boots", "Iron Boots", {
    triggers = {"PULSE"},

    basePrice = 5,
    rarity = lp.rarities.UNCOMMON,

    activateDescription = loc("Gives slot {lootplot:POINTS_COLOR}+2 points{/lootplot:POINTS_COLOR}. (Permanently)"),

    onActivate = function(ent)
        local slot = lp.itemToSlot(ent)
        if slot then
            lp.modifierBuff(slot, "pointsGenerated", 2)
        end
    end
})


defBoots("emerald_boots", "Emerald Boots", {
    triggers = {"REROLL"},

    basePrice = 5,
    rarity = lp.rarities.UNCOMMON,

    activateDescription = loc("Gives slot {lootplot:POINTS_COLOR}+2 points{/lootplot:POINTS_COLOR}. (Permanently)"),

    onActivate = function(ent)
        local slot = lp.itemToSlot(ent)
        if slot then
            lp.modifierBuff(slot, "pointsGenerated", 2)
        end
    end
})



--[[
goldsmith sub-archetype: 
]]
local MONEY_REQ = assert(consts.GOLDSMITH_MONEY_REQUIREMENT)
local POINT_MOD = 8
defBoots("golden_boots", "Golden Boots", {
    triggers = {"PULSE"},

    basePrice = 10,
    rarity = lp.rarities.RARE,

    activateDescription = interp("If balance is more than $%{moneyReq},\nGives slot {lootplot:POINTS_COLOR}+%{points} points"){
        moneyReq = MONEY_REQ,
        points = POINT_MOD
    },

    onActivate = function(ent)
        local slot = lp.itemToSlot(ent)
        if slot and (lp.getMoney(ent) or 0) > MONEY_REQ then
            lp.modifierBuff(slot, "pointsGenerated", POINT_MOD)
        end
    end
})



do
local POINTS_BUFF = 10

defBoots("boot_of_doom", "Boot of doom", {
    triggers = {"PULSE"},

    basePrice = 6,
    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(3),

    activateDescription = interp("Give all target {lootplot:DOOMED_COLOR}DOOMED{/lootplot:DOOMED_COLOR} slots {lootplot:POINTS_COLOR}+%{points} points"){
        points = POINTS_BUFF
    },

    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.doomCount
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", POINTS_BUFF)
        end
    }
})
end



--[[

TODO: Do leather-boot here.
(Do we even need leather-boot...?)

]]
