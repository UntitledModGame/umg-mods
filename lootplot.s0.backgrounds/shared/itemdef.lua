---@param self lootplot.ItemEntity
local function onBGItemActivate(self)
    return lp.backgrounds.setBackground(self.targetBackground)
end

---@param name string
---@param def lootplot.backgrounds.BackgroundInfo
---@param eattr table?
return function(name, def, eattr)
    lp.backgrounds.registerBackground(name, def)

    eattr = eattr or {}
    local attr = {
        name = def.name,
        description = def.description,
        image = def.icon,

        triggers = {"PULSE"},
        targetBackground = name,
        doomCount = 1,

        onActivate = onBGItemActivate
    }
    -- Overrides
    for k, v in pairs(eattr) do
        attr[k] = v
    end

    lp.defineItem(name, attr)
end
