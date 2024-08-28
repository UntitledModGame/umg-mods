
local loc = localization.localize


local function defineSword(mineral_type, name, tier)
    local etypeName = mineral_type .. "_sword"
    local image = mineral_type .. "_sword"

    lp.defineItem(etypeName, {
        basePointsGenerated = tier * 5,
        image = image,
        name = loc(name .. " Sword"),

        rarity = lp.rarities.COMMON,

        minimumLevelToSpawn = tier,
        baseBuyPrice = 1 * tier,
    })
end



local function defineAxe(mineral_type, name, tier)
    local etypeName = mineral_type .. "_axe"
    local image = mineral_type .. "_axe"

    lp.defineItem(etypeName, {
        image = image,
        name = loc(name .. " Axe"),

        baseMoneyGenerated = 1,
        targetActivationDescription = loc("{lp_targetColor}Earn points for every target item."),

        rarity = lp.rarities.RARE,
        minimumLevelToSpawn = 4,

        targetType = "ITEM",
        targetShape = lp.targets.KNIGHT_SHAPE,

        targetActivate = function(selfEnt, ppos, targetEnt)
            lp.addPoints(selfEnt, selfEnt.pointsGenerated or 0)
        end
    })
end



local minerals = {
    {type = "iron", name = "Iron", tier = 1},
    {type = "steel", name = "Steel", tier = 2},
    {type = "ruby", name = "Ruby", tier = 3},
}


for _, t in ipairs(minerals) do
    defineSword(t.type, t.name, t.tier)
    defineAxe(t.type, t.name, t.tier)
end


