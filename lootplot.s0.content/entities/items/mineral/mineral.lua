
local loc = localization.localize


local function defineMineral(name, etype)
    etype.baseMaxActivations = etype.baseMaxActivations or 50
    -- etype.baseTraits = {}

    lp.defineItem(name, etype)
end



local function defineSword(mineral_type, name, rank)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_sword"
    local image = mineral_type .. "_sword"

    assert(rank < 6, "raritys dont go this high!! welp!")
    local rarity = lp.rarities.RARITY_LIST[rank + 1]

    defineMineral(etypeName, {
        basePointsGenerated = rank * 5,
        image = image,
        name = loc(name .. " Sword"),

        rarity = rarity,

        basePrice = 1 * rank,
    })
end



local function defineAxe(mineral_type, name, rank)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_axe"
    local image = mineral_type .. "_axe"

    assert(rank < 6, "raritys dont go this high!! welp!")
    local rarity = lp.rarities.RARITY_LIST[rank + 1]

    defineMineral(etypeName, {
        image = image,
        name = loc(name .. " Axe"),

        rarity = rarity,

        basePrice = 2 * rank,
        basePointsGenerated = 2 * rank,

        shape = lp.targets.KNIGHT_SHAPE,

        target = {
            type = "ITEM",
            description = loc("{lootplot.targets:COLOR}Earn points for every target item."),
            activate = function(selfEnt, ppos, targetEnt)
                lp.addPoints(selfEnt, selfEnt.pointsGenerated or 0)
            end
        }
    })
end



local minerals = {
    {type = "iron", name = "Iron", rank = 1},
    {type = "steel", name = "Steel", rank = 2},
    {type = "ruby", name = "Ruby", rank = 3},
}


for _, t in ipairs(minerals) do
    defineSword(t.type, t.name, t.rank)
    defineAxe(t.type, t.name, t.rank)
end


