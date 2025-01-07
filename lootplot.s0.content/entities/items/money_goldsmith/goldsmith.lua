
local loc = localization.localize
local interp = localization.newInterpolator

local consts = require("shared.constants")
local MONEY_REQUIREMENT = assert(consts.GOLDSMITH_MONEY_REQUIREMENT)


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




local function percentageOfBalanceGetter(percentage)
    return function(ent)
        local money = lp.getMoney(ent)
        if money then
            return money * percentage
        end
        return 0
    end
end


local SILV_RING_DESC = interp("Earn points equal to the current balance.")

local function defSilvRing(id,name,trigger)
    defItem(id, {
        name = loc(name),
        triggers={trigger},

        activateDescription = function(ent)
            return SILV_RING_DESC({
                balance = lp.getMoney(ent) or 0
            })
        end,

        basePrice = 6,
        basePointsGenerated = 0,

        lootplotProperties = {
            modifiers = {
                pointsGenerated = percentageOfBalanceGetter(1)
            }
        },

        rarity = lp.rarities.RARE,
    })
end


defSilvRing("silver_pulse_ring", "Silver Pulse Ring", "PULSE")
defSilvRing("silver_reroll_ring", "Silver Reroll Ring", "REROLL")




local GOLD_RING_DESC = interp("Earn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} of interest for every {lootplot:MONEY_COLOR}$10{/lootplot:MONEY_COLOR} you have. (Max of {lootplot:MONEY_COLOR}$20{/lootplot:MONEY_COLOR})")

local function defGoldRing(id, name, trigger)
    defItem(id, {
        name = loc(name),
        triggers = {trigger},

        activateDescription = function(ent)
            return GOLD_RING_DESC({
                balance = lp.getMoney(ent) or 0
            })
        end,

        basePrice = 8,
        baseMoneyGenerated = 0,

        lootplotProperties = {
            maximums = {
                moneyGenerated = 20
            },
            modifiers = {
                moneyGenerated = function(ent)
                    local money = lp.getMoney(ent) or 0
                    local interest = math.floor(money / 10)
                    return interest
                end
            }
        },

        rarity = lp.rarities.EPIC,
    })
end

defGoldRing("gold_pulse_ring", "Gold Pulse Ring", "PULSE")
defGoldRing("gold_reroll_ring", "Gold Reroll Ring", "REROLL")


local TOPAZ_BUFF = 3
local TOPAZ_DESC = interp("If {lootplot:MONEY_COLOR}money more than $%{moneyReq}{/lootplot:MONEY_COLOR}, permanently gain %{pointBuff} points.\n"){
    pointBuff = 3,
    moneyReq = MONEY_REQUIREMENT
}

defItem("belt_topaz", {
    name = loc("Topaz Belt"),
    activateDescription = TOPAZ_DESC,

    basePointsGenerated = 20,
    baseMaxActivations = 2,

    onActivate = function(ent)
        if (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT then
            lp.modifierBuff(ent, "pointsGenerated", TOPAZ_BUFF, ent)
        end
    end,

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},
})





--[[

===========
items that only work when money > REQUIREMENT
===========
]]

local DEFAULT_ACTIVATE_DESC = loc("(Only works if {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} exceeds {lootplot:MONEY_COLOR}$%{amount}{/lootplot:MONEY_COLOR})", {
    amount = MONEY_REQUIREMENT
})

local DEFAULT_CAN_ACTIVATE = function(ent)
    return (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT
end



defItem("belt_ruby", {
    name = loc("Ruby Belt"),

    activateDescription = DEFAULT_ACTIVATE_DESC,
    canActivate = DEFAULT_CAN_ACTIVATE,

    baseMaxActivations = 10,
    basePointsGenerated = 50,

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},
})


defItem("gold_coin", {
    name = loc("Gold Coin"),

    activateDescription = DEFAULT_ACTIVATE_DESC,
    canActivate = DEFAULT_CAN_ACTIVATE,

    baseMaxActivations = 5,
    basePrice = 12,
    baseMultGenerated = 2,

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},
})



defItem("robbers_bag", {
    name = loc("Robbers Bag"),
    activateDescription = loc("Multiplies money by -1.5"),

    basePrice = 10,

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},
    doomCount = 3,

    onActivate = function(ent)
        local money = lp.getMoney(ent) or 0
        lp.setMoney(ent, money * -1.5)
    end
})




defItem("golden_spoon", {
    --[[
    Used as a way to "pivot into" goldsmith builds
    ]]
    triggers = {"PULSE"},

    activateDescription = DEFAULT_ACTIVATE_DESC,
    canActivate = DEFAULT_CAN_ACTIVATE,

    name = loc("Golden Spoon"),

    basePrice = 8,
    baseMoneyGenerated = 1,

    rarity = lp.rarities.UNCOMMON,
})




--[[


TODO: Implement `reroll_award` item.
TODO
TODO
TODO
TODO
TODO

It should be related to rerolling, and goldsmith-
work fine with money

]]


