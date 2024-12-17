

components.defineComponent("slot")
components.defineComponent("item")


components.defineComponent("plot")
-- ent.plot = Plot


components.defineComponent("buttonSlot")
-- Flag component denoting whether a slot is a bottom



components.defineComponent("lootplotTags")
-- a table of string-names; denoting what "traits" this etype has.
-- (Can only be a shcomp. Useful for proc-gen.)



components.defineComponent("onReroll")
components.defineComponent("onDestroy")
components.defineComponent("onActivate")

components.defineComponent("onDestroyClient")
components.defineComponent("onActivateClient")


components.defineComponent("repeatActivations")
-- bool: whether items should use all their activations in one go.

components.defineComponent("grubMoneyCap")
-- If money > ent.grubMoneyCap, the entity won't activate!!!
-- (Useful to encourage low-money builds.)



--[[
==================================================
Property definitions:
==================================================
]]

---@param propName string
---@param basePropName string
local function defBoolProperty(propName, basePropName)
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
local function defNumberProperty(propName, args)
    components.defineComponent(propName)
    components.defineComponent(args.base)

    -- auto-syncs a component, and defines it as a property!
    properties.defineNumberProperty(propName, {
        base = args.base,
        default = args.default,
    })
    sync.autoSyncComponent(propName, {
        type = "number",
        lerp = false,
        -- gotta be super accurate with properties
        numberSyncThreshold = 0.000001,
    })
end


local function defineNumberNoLerp(compName)
    components.defineComponent(compName)
    sync.autoSyncComponent(compName, {
        type = "number",
        lerp = false,
    })
end


defineNumberNoLerp("doomCount")
-- how many activations until deletion?

defineNumberNoLerp("lives")
-- How many "lives" the entity has (will be revived!)
-- (Does not work for `doomed` entities)

-- activation counts:
defineNumberNoLerp("totalActivationCount")
defineNumberNoLerp("activationCount") -- <<< set to 0 when `lp.resetEntity()` called

defineNumberNoLerp("lootplotRotation") -- <<< set to 0 when `lp.resetEntity()` called



--[[
    boolean properties for lootplot
]]
defBoolProperty("canItemMove", "baseCanItemMove")

defBoolProperty("canBeDestroyed", "baseCanBeDestroyed")

defBoolProperty("canSlotPropagate", "baseCanSlotPropagate")
-- Whether a slot will propagate the trigger to the item
-- TO DO: Do we want different behavior based on trigger types?


--[[
    number properties for lootplot
]]
defNumberProperty("price", {base="basePrice", default=5})

defNumberProperty("maxActivations", {base="baseMaxActivations", default=5})

defNumberProperty("pointsGenerated", {base="basePointsGenerated", default=0})

defNumberProperty("moneyGenerated", {base="baseMoneyGenerated", default=0})


sync.autoSyncComponent("lootplotTeam", {type = "string"})
