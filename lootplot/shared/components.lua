

components.defineComponent("slot")
components.defineComponent("item")


components.defineComponent("plot")
-- ent.plot = Plot


components.defineComponent("buttonSlot")
-- Flag component denoting whether a slot is a bottom



components.defineComponent("lootplotTags")
-- a table of string-names; denoting what "traits" this etype has.
-- (Can only be a shcomp. Useful for proc-gen.)



components.defineComponent("onDestroy")

components.defineComponent("onActivate")
components.defineComponent("onPostActivate") -- called AFTER everything else

components.defineComponent("onTriggered") -- fun(ent, triggerName, wasActivated)
-- called when `tryTriggerEntity` is called. NOTE: this function is called
-- even if the ent doesnt have the trigger!!!

components.defineComponent("onDestroyClient")
components.defineComponent("onActivateClient")


components.defineComponent("activateInstantly") -- causes an item to activate instantenously
components.defineComponent("foodItem") -- foodItem


-- fun(ent) -> boolean
-- returns true iff the entity is invincible
components.defineComponent("isInvincible")

-- This one is ONLY FOR SLOTS!!!
-- fun(slotEnt, itemEnt) returns true iff the item-entity should be invincible
components.defineComponent("isItemInvincible")



components.defineComponent("canAddItemToSlot")
-- fun(slotEnt, itemEnt) --> boolean
-- returns true iff the entity can be added to slot


components.defineComponent("repeatActivations")
-- bool: whether items should use all their activations in one go.

components.defineComponent("grubMoneyCap")
-- When this entity is activated, money is limited to `grubMoneyCap`.
-- (Useful to encourage low-money builds.)



components.defineComponent("name")
components.defineComponent("description")
components.defineComponent("activateDescription")



components.defineComponent("isEntityTypeUnlocked")
-- function(etype) -> boolean



components.defineComponent("winAchievement")
-- its a bit hacky... but used primarily for singleplayer starter-items.




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


local function defineBool(compName)
    components.defineComponent(compName)
    sync.autoSyncComponent(compName, {
        type = "boolean",
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


-- sticky/stuck components:
defineBool("sticky") -- itemEnt.sticky = true ::  When activated, becomes stuck.
defineBool("stuck") -- itemEnt.stuck = true :: Cannot be moved by the player

defineBool("stickySlot")
-- slotEnt.stickySlot = true :: Makes contained-item stuck when activated.

defineBool("canGoIntoDebt")
-- if this is true, negative moneyGenerated wont prevent activation.
-- instead, money will just go into negatives. (false by default obviously)

defineBool("hasBeenMoved") -- true if this entity has been moved; false otherwise.
-- used for `food` items.



--[[
    number properties for lootplot
]]
defNumberProperty("price", {base="basePrice", default=5})

defNumberProperty("maxActivations", {base="baseMaxActivations", default=5})


defNumberProperty("pointsGenerated", {base="basePointsGenerated", default=0})

defNumberProperty("moneyGenerated", {base="baseMoneyGenerated", default=0})

defNumberProperty("multGenerated", {base="baseMultGenerated", default=0})
-- ^^^ adds global-mult

defNumberProperty("bonusGenerated", {base="baseBonusGenerated", default=0})
-- ^^^ adds global-bonus


sync.autoSyncComponent("lootplotTeam", {type = "string"})
