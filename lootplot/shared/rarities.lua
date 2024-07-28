
---@alias lootplot.Rarity {color:objects.Color, index:number, name:string, rarityWeight:number, displayString:string}
---@return lootplot.Rarity
local function newRarity(name, rarity_weight, color)
    local cStr = ("Rarity: {wavy}{c r=%f g=%f b=%f}"):format(color.r, color.g, color.b)
    return {
        color = color,
        index = 1,
        name = name,
        rarityWeight = rarity_weight,
        displayString = cStr .. name
    }
end



local function hsl(h,s,l)
    return objects.Color(0,0,0)
        :setHSL(h,s/100,l/100)
end


local DEFAULT_RARITIES = {
    COMMON = newRarity("COMMON",   2,   hsl(110, 35, 55)),
    UNCOMMON = newRarity("UNCOMMON", 1.5, hsl(150, 66, 55)),
    RARE = newRarity("RARE",     1,   hsl(220, 90, 55)),
    EPIC = newRarity("EPIC",     0.4, hsl(275, 100,45)),
    LEGENDARY = newRarity("LEGENDARY",0.04,hsl(50, 90, 40)),
    MYTHIC = newRarity("MYTHIC",   0.004,hsl(330, 100, 35)),
    UNIQUE = newRarity("UNIQUE",   0.00, objects.Color.WHITE),
}


umg.answer("lootplot:getEntityTypeSpawnChance", function(etype)
    local rarity = etype.rarity
    ---@cast rarity lootplot.Rarity
    if rarity then
        return rarity.rarityWeight
    end
    return 1
end)




if client then
    local ORDER = 50
    umg.on("lootplot:populateDescription", ORDER, function(ent, arr)
        local rarity = ent.rarity
        ---@cast rarity lootplot.Rarity
        if rarity then
            arr:add(rarity.displayString)
        end
    end)
end


return DEFAULT_RARITIES
