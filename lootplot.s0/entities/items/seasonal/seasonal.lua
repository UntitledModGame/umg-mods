
local loc = localization.localize


local function getMonth()
    local temp = os.date("*t", os.time())
    return temp.month
end


local HALLOWEEN = 10
local CHRISTMAS = 12
local EASTER = 4


local function defineItem(season, id, etype)
    if season == getMonth() then
        etype.rarity = etype.rarity or lp.rarities.RARE
    else
        -- item is not accessible if its not the holiday.
        etype.rarity = lp.rarities.UNIQUE
    end

    etype.basePrice = etype.basePrice or 8
    etype.baseMaxActivations = etype.baseMaxActivations or 10
    etype.image = id
    etype.triggers = {"PULSE"}
    lp.defineItem("lootplot.s0:"..id, etype)
end



defineItem(HALLOWEEN, "jack_o_lantern", {
    name = loc("Jack o Lantern"),
    description = loc("Happy Halloween!"),
    basePointsGenerated = 30,
    baseMultGenerated = 0.4,
})


defineItem(CHRISTMAS, "santa_hat", {
    name = loc("Santa Hat"),
    description = loc("Merry Christmas!"),
    baseBonusGenerated = 2,
    baseMultGenerated = 0.4,
})


defineItem(EASTER, "seasonal_easter_eggs", {
    name = loc("Easter Eggs"),
    description = loc("Happy Easter!"),
    baseBonusGenerated = -3,
    baseMultGenerated = 0.9,
})

