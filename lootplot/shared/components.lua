

---@param propName string
---@param basePropName string
local function defineBasicBoolean(propName, basePropName)
    -- auto-syncs a component, and defines it as a property!
    properties.defineBooleanProperty(propName, {
        base = basePropName,
        default = false,
    })
    sync.autoSyncComponent(propName, {
        type = "boolean",
    })
end


---@param propName string
---@param args {base:string, default:number}
local function defineBasicNumber(propName, args)
    -- auto-syncs a component, and defines it as a property!
    properties.defineNumberProperty(propName, {
        base = args.base,
        default = args.default,
    })
    sync.autoSyncComponent(propName, {
        type = "number",
        lerp = false,
    })
end




--[[
    boolean properties for lootplot
]]
defineBasicBoolean("canMove", "baseCanMove")

defineBasicBoolean("canDestroy", "baseCanDestroy")

defineBasicBoolean("canSell", "baseCanSell")-- Do we need this??
-- This is almost identical to canDestroy

defineBasicBoolean("canActivate", "baseCanActivate")

defineBasicBoolean("canReroll", "baseCanReroll")


--[[
    number properties for lootplot
]]
defineBasicNumber("sellPrice", {base="baseSellPrice", default=1})

defineBasicNumber("buyPrice", {base="baseBuyPrice", default=1})

defineBasicNumber("maxActivations", {base="baseMaxActivations", default=10})

defineBasicNumber("pointsGenerated", {base="basePointsGenerated", default=0})

defineBasicNumber("moneyGenerated", {base="baseMoneyGenerated", default=0})

defineBasicNumber("power", {base="basePower", default=0})
-- TODO: should we keep this property?

