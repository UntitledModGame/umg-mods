
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defFiscal(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




local function percentageOfBalanceGetter(percentage)
    return function(ent)
        local tier = lp.tiers.getTier(ent)
        local money = lp.getMoney(ent)
        if money then
            return money * percentage * tier
        end
        return 0
    end
end


local BISHOP_RING_DESC = interp("Earn points equal to %{val}% of current balance.")

local function defSilvRing(id,name,trigger)
    defFiscal(id, {
        name = loc(name),
        triggers={trigger},

        activateDescription = function(ent)
            return BISHOP_RING_DESC({
                val = ent.tier * 20
            })
        end,

        tierUpgrade = {
            description = loc("Increases percentage!")
        },

        basePrice = 6,
        basePointsGenerated = 0,

        lootplotProperties = {
            modifiers = {
                pointsGenerated = percentageOfBalanceGetter(0.20)
            }
        },

        rarity = lp.rarities.RARE,
    })
end


defSilvRing("silver_pulse_ring", "Silver Pulse Ring", "PULSE")
defSilvRing("silver_reroll_ring", "Silver Reroll Ring", "REROLL")




local SILVER_RING_DESC = interp("Earn money equal to %{val}% of current balance.\n(Max of $20)")

local function defGoldRing(id, name, trigger)
    defFiscal(id, {
        name = loc(name),
        triggers = {trigger},

        activateDescription = function(ent)
            return SILVER_RING_DESC({
                val = ent.tier * 10
            })
        end,

        tierUpgrade = {
            description = loc("Increases percentage!")
        },

        basePrice = 8,
        baseMoneyGenerated = 0,

        lootplotProperties = {
            maximums = {
                moneyGenerated = 20
            },
            modifiers = {
                moneyGenerated = percentageOfBalanceGetter(0.1)
            }
        },

        rarity = lp.rarities.EPIC,
    })
end

defGoldRing("gold_pulse_ring", "Gold Pulse Ring", "PULSE")
defGoldRing("gold_reroll_ring", "Gold Reroll Ring", "REROLL")
