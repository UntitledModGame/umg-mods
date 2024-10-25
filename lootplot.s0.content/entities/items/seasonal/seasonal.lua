
local loc = localization.localize


local function getMonth()
    local temp = os.date("*t", os.time())
    return temp.month
end


local HALLOWEEN = 10
local CHRISTMAS = 12
local EASTER = 4


local function defineItem(id, etype)
    etype.image = id
    lp.defineItem("lootplot.s0.content:"..id, etype)
end



if getMonth() == HALLOWEEN then
    defineItem("jack_o_lantern", {
        name = loc("Jack o Lantern"),
        description = loc("Happy Halloween!"),
        rarity = lp.rarities.RARE,
        basePointsGenerated = 30,
    })
end


if getMonth() == CHRISTMAS then
    defineItem("santa_hat", {
        name = loc("Santa Hat"),
        description = loc("Merry Christmas!"),
        rarity = lp.rarities.RARE,
        basePointsGenerated = 30,
    })
end


if getMonth() == EASTER then
    defineItem("seasonal_easter_eggs", {
        name = loc("Easter Eggs"),
        description = loc("Happy Easter!"),
        rarity = lp.rarities.RARE,
        basePointsGenerated = 30,
    })
end

