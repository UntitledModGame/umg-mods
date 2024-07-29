

components.defineComponent("slot")
components.defineComponent("item")


components.defineComponent("plot")
-- ent.plot = Plot


components.defineComponent("buttonSlot")
-- Flag component denoting whether a slot is a bottom

components.defineComponent("shopLock")
-- for shop-slots

components.defineComponent("costToUse")








--[[
==================================================
Property definitions:
==================================================
]]

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




sync.autoSyncComponent("totalActivationCount", {
    type = "number",
    lerp = false,
})

sync.autoSyncComponent("activationCount", {
    type = "number",
    lerp = false,
})


--[[
    boolean properties for lootplot
]]
defineBasicBoolean("canItemMove", "baseCanItemMove")

defineBasicBoolean("canBeDestroyed", "baseCanBeDestroyed")

defineBasicBoolean("canActivate", "baseCanActivate")

defineBasicBoolean("canSlotPropagate", "baseCanSlotPropagate")
-- Whether a slot will propagate the trigger to the item
-- TO DO: Do we want different behavior based on trigger types?


--[[
    number properties for lootplot
]]
defineBasicNumber("sellPrice", {base="baseSellPrice", default=1})

defineBasicNumber("buyPrice", {base="baseBuyPrice", default=1})

defineBasicNumber("maxActivations", {base="baseMaxActivations", default=5})

defineBasicNumber("pointsGenerated", {base="basePointsGenerated", default=0})

defineBasicNumber("moneyGenerated", {base="baseMoneyGenerated", default=0})

defineBasicNumber("power", {base="basePower", default=0})
-- TODO: should we keep this property?

sync.autoSyncComponent("shopLock", {type = "boolean"})
sync.autoSyncComponent("ownerPlayer", {type = "string"})
