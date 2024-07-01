

components.defineComponent("slot")
components.defineComponent("item")


components.defineComponent("plot")
-- ent.plot = Plot()


components.defineComponent("buttonSlot")
-- Flag component denoting whether a slot is a bottom







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




--[[
    boolean properties for lootplot
]]
defineBasicBoolean("canMove", "baseCanMove")

defineBasicBoolean("canDestroy", "baseCanDestroy")

defineBasicBoolean("", "")
--[[
It would be nice to have a unified property that represents
whether we have access over an item or not.

This way, shopSlots would be able to tag into this property only.
The same could be used for enemy item or other exotic item

Or maybe it's just best to keep the components horizontally decoupled.
Be assumptionless.
Doesn't matter if the shop slot definition is a bit more bloated.
]]

defineBasicBoolean("canSell", "baseCanSell")-- Do we need this??
-- This is almost identical to canDestroy

defineBasicBoolean("canActivate", "baseCanActivate")

defineBasicBoolean("canSlotPropagate", "baseCanSlotPropagate")
-- Whether a slot will propagate the trigger to the item
-- TO DO: Do we want different behavior based on trigger types?


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

