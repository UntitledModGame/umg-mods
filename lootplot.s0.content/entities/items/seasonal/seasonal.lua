
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
        etype.rarity = lp.rarities.RARE
    else
        -- item is not accessible if its not the holiday.
        etype.rarity = lp.rarities.UNIQUE
    end

    etype.image = id
    lp.defineItem("lootplot.s0.content:"..id, etype)
end



defineItem(HALLOWEEN, "jack_o_lantern", {
    name = loc("Jack o Lantern"),
    description = loc("Happy Halloween!"),
    basePointsGenerated = 10,
})


defineItem(CHRISTMAS, "santa_hat", {
    name = loc("Santa Hat"),
    description = loc("Merry Christmas!"),
    basePointsGenerated = 10,
})


defineItem(EASTER, "seasonal_easter_eggs", {
    name = loc("Easter Eggs"),
    description = loc("Happy Easter!"),
    basePointsGenerated = 10,
})

