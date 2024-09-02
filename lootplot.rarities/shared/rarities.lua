
---@alias lootplot.Rarity {color:objects.Color, index:number, name:string, rarityWeight:number, displayString:string}
---@return lootplot.Rarity
local function newRarity(name, rarity_weight, color)
    local cStr = localization.localize("{wavy}{c r=%f g=%f b=%f}%{name}{/c}{/wavy}", {
        name = name
    }):format(color.r, color.g, color.b)
    return {
        color = color,
        index = 1,
        name = name,
        rarityWeight = rarity_weight,
        displayString = cStr
    }
end



local function hsl(h,s,l)
    return objects.Color(0,0,0)
        :setHSL(h,s/100,l/100)
end


umg.answer("lootplot:getConstantSpawnWeight", function(etype)
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
        if rarity then
            local descString = localization.localize("Rarity") .. ": " .. rarity.displayString
            ---@cast rarity lootplot.Rarity
            if rarity then
                arr:add(descString)
            end
        end
    end)
end



-- Can override rarities in this table:
lp.rarities = {
    COMMON = newRarity("COMMON (I)", 2, hsl(110, 35, 55)),
    UNCOMMON = newRarity("UNCOMMON (II)", 1.5, hsl(150, 66, 55)),
    RARE = newRarity("RARE (III)", 1, hsl(220, 90, 55)),
    EPIC = newRarity("EPIC (IV)", 0.6, hsl(275, 100,45)),
    LEGENDARY = newRarity("LEGENDARY (V)",0.1, hsl(330, 100, 35)),
    MYTHIC = newRarity("MYTHIC (VI)", 0.02, hsl(50, 90, 40)),
    UNIQUE = newRarity("UNIQUE", 0.00, objects.Color.WHITE),
}

---@param r1 lootplot.Rarity
---@return number Rarity-weight of the rarity object. Lower means more rare.
function lp.rarities.getWeight(r1)
    return r1.rarityWeight
end
