
---@alias lootplot.rarities.Rarity {color:objects.Color, index:number, name:string, rarityWeight:number, displayString:string}
---@return lootplot.rarities.Rarity
local function newRarity(name, rarity_weight, color)
    local cStr = localization.localize("{wavy}{c r=%f g=%f b=%f}%{name}{/c}{/wavy}", {
        name = name
    }):format(color.r, color.g, color.b)

    local rarity = {
        color = color,
        index = 1,
        name = name,
        rarityWeight = rarity_weight,
        displayString = cStr
    }

    umg.register(rarity, "lootplot.rarities:" .. name)
    return rarity
end



local function hsl(h,s,l)
    return objects.Color(0,0,0)
        :setHSL(h,s/100,l/100)
end


umg.answer("lootplot:getConstantSpawnWeight", function(etype)
    local rarity = etype.rarity
    ---@cast rarity lootplot.rarities.Rarity
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
            ---@cast rarity lootplot.rarities.Rarity
            if rarity then
                arr:add(descString)
            end
        end
    end)
end



---Can override rarities in this table:
---
---Availability: Client and Server
lp.rarities = {
    COMMON = newRarity("COMMON (I)", 2, hsl(110, 35, 55)),
    UNCOMMON = newRarity("UNCOMMON (II)", 1.5, hsl(150, 66, 55)),
    RARE = newRarity("RARE (III)", 1, hsl(220, 90, 55)),
    EPIC = newRarity("EPIC (IV)", 0.6, hsl(275, 100,45)),
    LEGENDARY = newRarity("LEGENDARY (V)",0.1, hsl(330, 100, 35)),
    MYTHIC = newRarity("MYTHIC (VI)", 0.02, hsl(50, 90, 40)),

    -- Use this rarity when you dont want an item to spawn naturally.
    -- (Useful for easter-egg items, or items that can only be spawned by other items)
    UNIQUE = newRarity("UNIQUE", 0.00, objects.Color.WHITE),
}

local RARITY_LIST = objects.Array()

for _,r in pairs(lp.rarities) do
    RARITY_LIST:add(r)
end
RARITY_LIST:sortInPlace(function(a, b)
    return a.rarityWeight > b.rarityWeight
end)

---@type lootplot.rarities.Rarity[] | objects.Array
lp.rarities.RARITY_LIST = RARITY_LIST


---Availability: Client and Server
---@param r1 lootplot.rarities.Rarity
---@return number rarity weight of the rarity object. Lower means more rare.
function lp.rarities.getWeight(r1)
    return r1.rarityWeight
end


local function assertServer()
    if not server then
        umg.melt("This can only be called on client-side!", 3)
    end
end

function lp.rarities.setEntityRarity(ent, rarity)
    assertServer()
    ent.rarity = rarity
    sync.syncComponent(ent, "rarity")
end



local shiftTc = typecheck.assert("table", "number")

---@param rarity lootplot.rarities.Rarity
---@param delta number
---@return lootplot.rarities.Rarity
function lp.rarities.shiftRarity(rarity, delta)
    shiftTc(rarity, delta)
    for i,r in ipairs(RARITY_LIST) do
        if r.rarityWeight == rarity.rarityWeight then
            local choice = math.clamp(i + delta, 1, #RARITY_LIST)
            return RARITY_LIST[choice]
        end
    end
    -- FAILED!
    return rarity
end


for d=-5,5 do
    print(d, lp.rarities.shiftRarity(lp.rarities.RARE, d).name)
end