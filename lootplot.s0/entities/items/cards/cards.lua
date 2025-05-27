local loc = localization.localize


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end



local CARD_WIN_UNLOCK = 2 -- cards unlocked after 2 wins


local function defineCard(id, name, cardEType)
    cardEType.image = cardEType.image or id
    cardEType.name = loc(name)
    cardEType.rarity = cardEType.rarity or lp.rarities.RARE
    if not cardEType.listen then
        cardEType.triggers = cardEType.triggers or {"PULSE"}
    end

    cardEType.baseMaxActivations = 1
    cardEType.basePrice = cardEType.basePrice or 10
    cardEType.unlockAfterWins = cardEType.unlockAfterWins or CARD_WIN_UNLOCK

    lp.defineItem("lootplot.s0:" .. id, cardEType)
end


local function shuffled(tabl)
    local shufTabl = {}
    local len = #tabl
    for i=1,#tabl do
        local newIndex = (i % len) + 1
        shufTabl[newIndex] = tabl[i]
    end
    return shufTabl
end


---@param tabl Entity[]
---@param shufFunc fun(e:Entity, e2:Entity)
local function apply(tabl, shufFunc)
    for i=1, #tabl-1, 2 do
        local e1, e2 = tabl[i], tabl[i+1]
        shufFunc(e1, e2)
    end
end



local function shuffleTargetShapes(selfEnt)
    local targets = lp.targets.getTargets(selfEnt)
    if not targets then
        return
    end

    local itemEntities = {}
    local itemEntShapes = {}

    for _, ppos in ipairs(targets) do
        local itemEnt = lp.posToItem(ppos)
        if itemEnt then
            itemEntities[#itemEntities+1] = itemEnt
            itemEntShapes[#itemEntities] = itemEnt.shape
        end
    end

    -- Shuffle shapes
    itemEntShapes = shuffled(itemEntShapes)

    -- Assign shapes
    for i, itemEnt in ipairs(itemEntities) do
        if itemEnt.shape ~= itemEntShapes[i] then
            lp.targets.setShape(itemEnt, itemEntShapes[i])
        end
    end
end

defineCard("star_card", "Star Card", {
    activateDescription = loc("Shuffle {lootplot.targets:COLOR}target-shapes{/lootplot.targets:COLOR} between items"),
    rarity = lp.rarities.EPIC,
    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM",
    },

    onActivate = shuffleTargetShapes
})


--[[
This is a food-item, but it is defined OUTSIDE of `foods`.
(Because theres helper-functions in this file; also its pretty much identical to star-card)
]]
defItem("star", "Star", {
    activateDescription = loc("Shuffle {lootplot.targets:COLOR}target-shapes{/lootplot.targets:COLOR} between items"),
    rarity = lp.rarities.EPIC,
    foodItem = true,
    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM",
    },
    onActivate = shuffleTargetShapes
})



defineCard("hearts_card", "Hearts Card", {
    shape = lp.targets.VerticalShape(1),

    activateDescription = loc("Swaps {lootplot:LIFE_COLOR}lives{/lootplot:LIFE_COLOR} between items"),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return targEnt.lives
        end
    },

    onActivate = function(selfEnt)
        local targets = shuffled(
            objects.Array(lp.targets.getConvertedTargets(selfEnt))
        )
        apply(targets, function(e1,e2)
            local l1 = e1.lives or 0
            local l2 = e2.lives or 0
            e1.lives = l2
            e2.lives = l1
        end)
    end,

    rarity = lp.rarities.EPIC
})



defineCard("doomed_card", "Doomed Card", {
    shape = lp.targets.VerticalShape(1),

    activateDescription = loc("Shuffle {lootplot:DOOMED_LIGHT_COLOR}DOOM-COUNT{/lootplot:DOOMED_LIGHT_COLOR} between target items"),

    target = {
        type = "ITEM",
        filter = function (selfEnt, ppos, targetEnt)
            return targetEnt.doomCount
        end
    },

    onActivate = function(selfEnt)
        local targets = shuffled(
            lp.targets.getConvertedTargets(selfEnt)
        )
        apply(targets, function(e1,e2)
            local m1 = e1.doomCount or 0
            local m2 = e2.doomCount or 0
            e1.doomCount = m2
            e2.doomCount = m1
        end)
    end,

    rarity = lp.rarities.EPIC,
})





local PRICE_CHANGE = 4

defineCard("price_card", "Price Card", {
    shape = lp.targets.VerticalShape(2),
    activateDescription = loc("Decrease price of below items by {lootplot:MONEY_COLOR}$%{x}{/lootplot:MONEY_COLOR}.\nIncrease price of above items by {lootplot:MONEY_COLOR}$%{x2}{/lootplot:MONEY_COLOR}", {
        x = PRICE_CHANGE,
        x2 = PRICE_CHANGE
    }),

    target = {
        type = "ITEM",
        filter = function(targetEnt)
            return targetEnt.price
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if not selfPos then return end
            local _,dy = selfPos:getDifference(ppos)
            if dy < 0 then
                lp.modifierBuff(targetEnt, "price", PRICE_CHANGE, selfEnt)
            elseif dy > 0 then
                lp.modifierBuff(targetEnt, "price", -PRICE_CHANGE, selfEnt)
            end
        end
    },

    rarity = lp.rarities.EPIC,
})


defineCard("spades_card", "Spades Card", {
    shape = lp.targets.UpShape(2),

    activateDescription = loc("Shuffle positions of target items"),

    target = {
        type = "ITEM",
    },

    onActivate = function(selfEnt)
        local targets = lp.targets.getTargets(selfEnt)
        if not targets then
            return
        end

        local slots = objects.Array(targets):map(lp.posToSlot)
        slots = shuffled(slots)

        -- Swap item positions
        for i = 1, #slots - 1 do
            local s1 = slots[i]
            local s2 = slots[i + 1]
            local s1p = lp.getPos(s1)
            local s2p = lp.getPos(s2)
            if s1p and s2p and lp.canSwapItems(s1p, s2p) then
                lp.swapItems(s1p, s2p)
            end
        end
    end
})



defineCard("multiplier_bonus_card", "Multiplier Bonus Card", {
    activateDescription = loc("Swaps {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} and {lootplot:POINTS_MULT_COLOR}Multiplier{/lootplot:POINTS_MULT_COLOR}"),

    onActivate = function(ent)
        local mult, bonus = lp.getPointsMult(ent), lp.getPointsBonus(ent)
        local ppos = lp.getPos(ent)
        if ppos and mult and bonus then
            lp.wait(ppos, 0.4) -- delay just for extra effect
            lp.setPointsBonus(ent, mult)
            lp.setPointsMult(ent, bonus)
        end
    end,

    baseMaxActivations = 1,
    basePrice = 10,
    rarity = lp.rarities.LEGENDARY,
})


defineCard("multiplier_money_card", "Multiplier Money Card", {
    activateDescription = loc("Swaps {lootplot:MONEY_COLOR}Money{/lootplot:MONEY_COLOR} and {lootplot:POINTS_MULT_COLOR}Multiplier{/lootplot:POINTS_MULT_COLOR}"),

    onActivate = function(ent)
        local mult, money = lp.getPointsMult(ent), lp.getMoney(ent)
        local ppos = lp.getPos(ent)
        if ppos and mult and money then
            lp.wait(ppos, 0.4) -- delay just for extra effect
            lp.setMoney(ent, mult)
            lp.setPointsMult(ent, money)
        end
    end,

    doomCount = 4,

    baseMaxActivations = 1,
    basePrice = 10,
    rarity = lp.rarities.LEGENDARY,
})





defineCard("trigger_swap_card", "Trigger Swap Card", {
    activateDescription = loc("Swaps {lootplot:TRIGGER_COLOR}Triggers{/lootplot:TRIGGER_COLOR} between items"),

    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return targEnt.triggers
        end
    },

    onActivate = function(selfEnt)
        local targets = shuffled(
            objects.Array(lp.targets.getConvertedTargets(selfEnt))
        )
        apply(targets, function(e1,e2)
            local t1 = e1.triggers or {}
            local t2 = e2.triggers or {}
            lp.setTriggers(e1, t2)
            lp.setTriggers(e2, t1)
        end)
    end,

    rarity = lp.rarities.LEGENDARY
})


