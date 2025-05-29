
local loc = localization.localize


--[[
The idea is that systems/mods can give attributes to these slots,
and players will attempt to destroy them.

EG:
Stone-slot:
Generates +4 mult
(3 lives)

]]


lp.defineSlot("lootplot.s0:stone_slot", {
    name = loc("Stone slot"),
    image = "stone_slot",

    triggers = {"DESTROY"},

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    baseMaxActivations = 6,

    rarity = lp.rarities.UNIQUE,
})



lp.defineSlot("lootplot.s0:auto_stone_slot", {
    --[[
    same as stone-slot, but is automatically given properties.
    ]]
    name = loc("Stone slot"),
    image = "stone_slot",

    triggers = {"DESTROY"},

    init = function(ent)
        local r = lp.SEED:randomMisc()
        if r < 0.25 then
            lp.modifierBuff(ent, "moneyGenerated", 3)
        elseif r < 0.5 then
            lp.modifierBuff(ent, "multGenerated", 6)
        elseif r < 0.75 then
            lp.modifierBuff(ent, "bonusGenerated", 25)
        else
            lp.modifierBuff(ent, "pointsGenerated", 250)
        end

        -- todo: is this a good value? I think its "fine"
        ent.lives = lp.SEED:randomMisc(28,34)
    end,

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    baseMaxActivations = 40,

    rarity = lp.rarities.EPIC,
})



