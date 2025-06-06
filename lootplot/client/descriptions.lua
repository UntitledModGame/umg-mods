
--[[
we need this to load first,
(since we access lp.COLORS)
]]
require("shared.exports")


local loc = localization.localize
local interp = localization.newInterpolator


local INVALID_ENTITY = loc("INVALID ENTITY")

---@param txt localization.Interpolator
---@param ent Entity
local function funcLocEnt(txt, ent)
    --[[
    we need a function to interpolate the variables per frame!
    ]]
    return function()
        if umg.exists(ent) then
            return txt(ent)
        end

        return INVALID_ENTITY
    end
end

--[[

ORDER = 10 trigger
ORDER = 20 filter
ORDER = 30 action

ORDER = 50 misc
ORDER = 60 important misc
]]


umg.on("lootplot:populateActivateDescription", 30, function(ent, arr)
    if ent.activateDescription then
        if type(ent.activateDescription) == "string" then
            -- should already be localized:
            arr:add(ent.activateDescription)
        elseif objects.isCallable(ent.activateDescription) then
            arr:add(function()
                -- need to pass ent manually as a closure
                if umg.exists(ent) then
                    return ent.activateDescription(ent)
                end
                return ""
            end)
        end
    end
end)



do
local C1 = ("c r=%.2f g=%.2f b=%.2f"):format(unpack(lp.COLORS.GRUB_COLOR))
local C2 = ("c r=%.2f g=%.2f b=%.2f"):format(unpack(lp.COLORS.GRUB_COLOR_LIGHT))

local GRUB_CAP = interp(
    ("{%s}{wavy}GRUB-%%{grubMoneyCap}:{/wavy}{/c} {%s}Limits money to $%%{grubMoneyCap}{/c}")
    :format(C1,C2)
)

umg.on("lootplot:populateActivateDescription", 31, function(ent, arr)
    if ent.grubMoneyCap then
        arr:add(GRUB_CAP(ent))
    end
end)

end






local function isDoomedBeforeActivationsRunOut(ent)
    if ent.doomCount then
        return (math.max(ent.doomCount, 1) + (ent.lives or 0)) <= ent.maxActivations
    end
end

---@param ent Entity
---@return number?
---@return number?
local function tryGetActivations(ent)
    if ent.maxActivations  then
        local activations = ent.activationCount or 0
        if ent.doomCount and isDoomedBeforeActivationsRunOut(ent) then
            -- HACK: This item will get destroyed BEFORE running out of activations.
            return -- Thus, no point in displaying.
        end

        local remaining = ent.maxActivations - activations
        local total = ent.maxActivations
        return remaining, total
    end
end

local function getTriggerListString(triggers)
    local buf = objects.Array()
    for _,t in ipairs(triggers) do
        local displayName = lp.getTriggerDisplayName(t)
        buf:add(displayName)
    end
    return table.concat(buf, ", ")
end


local TRIGGER_LIST = interp("{c r=0.6 g=0.6 b=0.7}Activates On: {lootplot:TRIGGER_COLOR}{wavy}%{trigger}{/wavy}{/lootplot:TRIGGER_COLOR}")

local TRIGGER_LIST_ACTIVS = interp("{c r=0.6 g=0.6 b=0.7}Activates On: {lootplot:TRIGGER_COLOR}{wavy}%{trigger}{/wavy}{/lootplot:TRIGGER_COLOR} %{activationColor}(%{remaining}/%{total})")

umg.on("lootplot:populateTriggerDescription", 10, function(ent, arr)
    local triggers = ent.triggers
    if triggers and #triggers > 0 then
        arr:add(function()
            if umg.exists(ent) then
                local remaining, total = tryGetActivations(ent)
                if remaining then
                    return TRIGGER_LIST_ACTIVS({
                        trigger = getTriggerListString(triggers),
                        remaining = remaining,
                        total = total,
                        activationColor = ((remaining == 0) and "{c r=1 g=0.1 b=0.1}") or ""
                    })
                else
                    return TRIGGER_LIST({
                        trigger = getTriggerListString(triggers),
                    })
                end
            end
            return ""
        end)
    end
end)






local VERB_CTX = {
    context = "Should be translated within a verb context"
}

local EARN_POINTS = interp("Earns points: {lootplot:POINTS_COLOR}%{pointsGenerated:.1f}{/lootplot:POINTS_COLOR}", VERB_CTX)
local STEAL_POINTS = interp("{lootplot:BAD_COLOR}Steals points: {lootplot:POINTS_COLOR}%{pointsGenerated:.1f}{/lootplot:BAD_COLOR}", VERB_CTX)
local POINT_INFO = interp("  ({lootplot:POINTS_MOD_COLOR}%{mod}{/lootplot:POINTS_MOD_COLOR} x {lootplot:POINTS_MULT_COLOR}%{mult}{/lootplot:POINTS_MULT_COLOR})")

local function addPointsDescription(ent, arr)
    arr:add(function()
        if not umg.exists(ent) then
            return ""
        end
        local pgen = ent.pointsGenerated
        if pgen == 0 then return "" end
        local txt1
        if pgen >= 0 then
            txt1 = EARN_POINTS(ent)
        else
            txt1 = STEAL_POINTS(ent)
        end
        -- todo: this is kinda inefficient. OH WELL :)
        local _, mod, mult = properties.computeProperty(ent, "pointsGenerated")
        ---@cast mod number
        ---@cast mult number
        local append_txt = ""
        if mult ~= 1 then
            append_txt = POINT_INFO({
                mod = math.floor(mod),
                mult = math.floor(mult)
            })
        end
        return txt1 .. append_txt
    end)
end

local EARN_MONEY = interp("{lootplot:MONEY_COLOR}Earns $%{moneyGenerated:.1f}", VERB_CTX)
local COSTS_MONEY = interp("{lootplot:BAD_COLOR}Costs {lootplot:MONEY_COLOR}$%{cost:.1f}{/lootplot:MONEY_COLOR} to activate!")
local STEAL_MONEY = interp("{lootplot:BAD_COLOR}Steals {lootplot:MONEY_COLOR}$%{cost:.1f}{/lootplot:MONEY_COLOR}!")
-- Wahts difference between "costs" and "steals"?
-- A: steal will go into negative. Cost wont; it will prevent activation.

local function addMoneyDesc(ent, arr)
    arr:add(function()
        if not umg.exists(ent) then
            return ""
        end
        local mEarn = ent.moneyGenerated
        if mEarn == 0 then return "" end
        if mEarn >= 0 then
            return EARN_MONEY(ent)
        else
            local loseMoney = (ent.canGoIntoDebt and STEAL_MONEY) or COSTS_MONEY
            return loseMoney({
                cost = -ent.moneyGenerated
            })
        end
    end)
end


local GAIN_MULT = interp("Adds {lootplot:POINTS_MULT_COLOR}%{multGenerated:.1f} multiplier")
local LOSE_MULT = interp("{lootplot:BAD_COLOR}Subtracts %{multCost:.1f} multiplier!")

local function addMultDesc(ent, arr)
    arr:add(function()
        if not umg.exists(ent) then
            return ""
        end
        local multGen = ent.multGenerated
        if multGen == 0 then return "" end
        if multGen >= 0 then
            return GAIN_MULT(ent)
        else
            return LOSE_MULT({
                multCost = -ent.multGenerated
            })
        end
    end)
end


local GAIN_BONUS = interp("Adds {lootplot:BONUS_COLOR}%{bonusGenerated:.1f} bonus")
local LOSE_BONUS = interp("{lootplot:BAD_COLOR}Subtracts %{bonusCost:.1f} bonus!")

local function addBonusGen(ent, arr)
    arr:add(function()
        if not umg.exists(ent) then
            return ""
        end
        local bonusGen = ent.bonusGenerated
        if bonusGen == 0 then return "" end
        if bonusGen >= 0 then
            return GAIN_BONUS(ent)
        else
            return LOSE_BONUS({
                bonusCost = -ent.bonusGenerated
            })
        end
    end)
end


umg.on("lootplot:populateActivateDescription", 30, function(ent, arr)
    local multGen = ent.multGenerated
    if multGen and (multGen ~=0) then
        addMultDesc(ent, arr)
    end

    local bonusGen = ent.bonusGenerated
    if bonusGen and (bonusGen ~= 0) then
        addBonusGen(ent, arr)
    end

    local pgen = ent.pointsGenerated
    if pgen and (pgen ~= 0) then
        addPointsDescription(ent, arr)
    end

    local mEarn = ent.moneyGenerated
    if mEarn and (mEarn ~= 0) then
        addMoneyDesc(ent, arr)
    end
end)




--[[
-- ============================
-- OLD ACTIVATIONS DESCRIPTION:
-- ============================

local ACTIVATIONS = interp("Activations: {lootplot:POINTS_COLOR}%{remaining}/%{total}")
local NO_ACTIVATIONS = interp("{lootplot:BAD_COLOR}No Activations: %{remaining}/%{total}")

local function isDoomedBeforeActivationsRunOut(ent)
    if ent.doomCount then
        return (math.max(ent.doomCount, 1) + (ent.lives or 0)) <= ent.maxActivations
    end
end


umg.on("lootplot:populateDescription", 50, function(ent, arr)
    if ent.maxActivations  then
        local activations = ent.activationCount or 0
        if ent.doomCount and isDoomedBeforeActivationsRunOut(ent) then
            -- HACK: This item will get destroyed BEFORE running out of activations.
            return -- Thus, no point in displaying.
        end

        arr:add(function ()
            local remaining = ent.maxActivations - activations
            local vars = {
                remaining = remaining,
                total = ent.maxActivations
            }
            local interpolator = remaining > 0 and ACTIVATIONS or NO_ACTIVATIONS
            return interpolator(vars)
        end)
    end
end)

]]



umg.on("lootplot:populateDescriptionTags", 50, function(ent, arr)
    if ent.price then
        local txt = ("{wavy}{lootplot:MONEY_COLOR}$%.1f{/wavy}{/lootplot:MONEY_COLOR}")
            :format(ent.price)
        arr:add(txt)
    end
end)



local FLOAT = loc("{lootplot:TRIGGER_COLOR}{wavy}FLOATY:{/wavy}{/lootplot:TRIGGER_COLOR} Can be placed in the air!")
umg.on("lootplot:populateMetaDescription", 59, function(ent, arr)
    if lp.isItemEntity(ent) and lp.canItemFloat(ent) then
        arr:add(FLOAT)
    end
end)




local REPEATER = interp("{lootplot:REPEATER_COLOR}{wavy}REPEATER:{/wavy}{/lootplot:REPEATER_COLOR} {lootplot:REPEATER_COLOR_LIGHT}Activates %{maxActivations} times!")
umg.on("lootplot:populateMetaDescription", 59, function(ent, arr)
    if ent.repeatActivations then
        arr:add(REPEATER(ent))
    end
end)




local DOOMED_MULTI = interp("{wavy}{lootplot:DOOMED_COLOR}DOOMED %{doomCount}:{/lootplot:DOOMED_COLOR}{/wavy} {lootplot:DOOMED_LIGHT_COLOR}Destroyed after %{doomCount} activations!")
local DOOMED_1 = interp("{wavy}{lootplot:DOOMED_COLOR}DOOMED 1:{/lootplot:DOOMED_COLOR}{/wavy} {lootplot:DOOMED_LIGHT_COLOR}Destroyed when activated!")

local FOOD = loc("{wavy}{lootplot:CONSUMABLE_COLOR}FOOD:{/lootplot:CONSUMABLE_COLOR}{/wavy}{lootplot:CONSUMABLE_COLOR_LIGHT} Activated instantly!")


umg.on("lootplot:populateMetaDescription", 60, function(ent, arr)
    if (ent.foodItem and lp.isItemEntity(ent)) then
        arr:add(FOOD)
    end

    if ent.doomCount then
        local interpolator = (ent.doomCount <= 1 and DOOMED_1) or DOOMED_MULTI
        arr:add(funcLocEnt(interpolator, ent))
    end
end)

local EXTRA_LIFE = interp("{wavy}{lootplot:LIFE_COLOR}EXTRA LIVES:{/lootplot:LIFE_COLOR} %{lives}")
local INVINCIBLE = interp("{wavy}{lootplot:INFO_COLOR}INVINCIBLE:{/lootplot:INFO_COLOR}{/wavy} Cannot be destroyed!")

umg.on("lootplot:populateMetaDescription", 60, function(ent, arr)
    if ent.lives and ent.lives > 0 then
        arr:add(funcLocEnt(EXTRA_LIFE, ent))
    elseif lp.isInvincible(ent) then
        arr:add(INVINCIBLE)
    end
end)


local STUCK = loc("{wavy}{lootplot:STUCK_COLOR}STUCK:{/lootplot:STUCK_COLOR}{/wavy} {lootplot:BAD_COLOR}Cannot be moved!")
local STICKY = loc("{wavy}{lootplot:STUCK_COLOR}STICKY:{/lootplot:STUCK_COLOR}{/wavy} {lootplot:BAD_COLOR}Becomes STUCK when activated!")
local STICKY_SLOT = loc("{wavy}{lootplot:STUCK_COLOR}STICKY SLOT: {/lootplot:STUCK_COLOR}{/wavy}{lootplot:BAD_COLOR}Makes items STUCK!")

umg.on("lootplot:populateMetaDescription", 60, function(ent, arr)
    if ent.stuck then
        arr:add(STUCK)
    elseif ent.sticky then
        -- item shouldnt display sticky AND stuck simultaneously
        arr:add(STICKY)
    end

    if ent.stickySlot and lp.isSlotEntity(ent) then
        arr:add(STICKY_SLOT)
    end
end)
