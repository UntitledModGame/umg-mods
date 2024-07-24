
---@alias lootplot.Rarity {color:objects.Color, index:number, name:string, rarityWeight:number}
---@return lootplot.Rarity
local function newRarity(name, rarity_weight, color)
    return {
        color = color,
        index = 1,
        name = name,
        rarityWeight = rarity_weight
    }
end



local function hsl(h,s,l)
    return objects.Color(0,0,0)
        :setHSL(h,s/100,l/100)
end


local DEFAULT_RARITIES = {
    newRarity("COMMON",   2,   hsl(110, 35, 55)),
    newRarity("UNCOMMON", 1.5, hsl(150, 66, 55)),
    newRarity("RARE",     1,   hsl(220, 90, 55)),
    newRarity("EPIC",     0.4, hsl(275, 100,45)),
    newRarity("LEGENDARY",0.05,hsl(50, 90, 40)),
    newRarity("MYTHIC",   0.01,hsl(330, 100, 35)),
    newRarity("UNIQUE",   0.00, objects.Color.WHITE),
}

return DEFAULT_RARITIES
