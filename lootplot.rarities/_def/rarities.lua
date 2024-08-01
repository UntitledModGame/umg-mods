---@meta

---@return lootplot.Rarity
local function newRarity(name, rarity_weight, color)
end

---@param r1 lootplot.Rarity
---@param r2 lootplot.Rarity
---@return number comparison 1 if `r1` rarer than `r2`, 0 if `r1` is as rare as `r2`, -1 if `r2` is rarer than `r1`.
function lp.rarities.compare(r1, r2)
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

