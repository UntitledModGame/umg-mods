---@meta

---@return lootplot.Rarity
local function newRarity(name, rarity_weight, color)
end

---@param r1 lootplot.Rarity
---@return number Rarity-weight of the rarity object. Lower means more rare.
function lp.rarities.getWeight(r1)
end


-- Can override rarities in this table:
lp.rarities = {
    COMMON = newRarity("COMMON",   2,   hsl(110, 35, 55)),
    UNCOMMON = newRarity("UNCOMMON", 1.5, hsl(150, 66, 55)),
    RARE = newRarity("RARE",     1,   hsl(220, 90, 55)),
    EPIC = newRarity("EPIC",     0.4, hsl(275, 100,45)),
    LEGENDARY = newRarity("LEGENDARY",0.04,hsl(50, 90, 40)),
    MYTHIC = newRarity("MYTHIC",   0.004,hsl(330, 100, 35)),
    UNIQUE = newRarity("UNIQUE",   0.00, objects.Color.WHITE),
}

