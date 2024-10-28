

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

local SEPARATOR = "------------------------"

umg.on("lootplot:populateDescription", -10, function(ent, arr)
    if ent.description then
        local typ = type(ent.description)
        if typ == "string" then
            -- should already be localized:
            arr:add(ent.description)
            arr:add(SEPARATOR)
        elseif typ == "function" then
            arr:add(function()
                -- need to pass ent manually as a closure
                if umg.exists(ent) then
                    return ent.description(ent)
                end
            end)
            arr:add(SEPARATOR)
        end
    end
end)





local function getTriggerListString(triggers)
    local buf = objects.Array()
    for _,t in ipairs(triggers) do
        local displayName = lp.getTriggerDisplayName(t)
        buf:add(displayName)
    end
    return table.concat(buf, ", ")
end

local TRIGGER_LIST = interp("Trigger: {lootplot:TRIGGER_COLOR}{wavy}%{trigger}")

umg.on("lootplot:populateDescription", 10, function(ent, arr)
    local triggers = ent.triggers
    if triggers and #triggers > 0 then
        arr:add(TRIGGER_LIST({trigger = getTriggerListString(triggers)}))
    end
end)






local VERB_CTX = {
    context = "Should be translated within a verb context"
}

local EARN_POINTS = interp("Points generated: {lootplot:POINTS_COLOR}%{pointsGenerated:.1f}{/lootplot:POINTS_COLOR}", VERB_CTX)
local STEAL_POINTS = interp("{lootplot:BAD_COLOR}Steals points: {lootplot:POINTS_COLOR}%{pointsGenerated:.1f}{/lootplot:BAD_COLOR}", VERB_CTX)
local POINT_INFO = interp("  ({lootplot:POINTS_MOD_COLOR}%{mod}{/lootplot:POINTS_MOD_COLOR} x {lootplot:POINTS_MULT_COLOR}%{mult} mult{/lootplot:POINTS_MULT_COLOR})")

local function addPointsDescription(ent, arr, pgen)
    arr:add(function()
        if not umg.exists(ent) then
            return ""
        end
        local txt1
        if pgen > 0 then
            txt1 = EARN_POINTS(ent)
        else
            txt1 = STEAL_POINTS(ent)
        end
        -- todo: this is kinda inefficient. OH WELL :)
        local _, mod, mult = properties.computeProperty(ent, "pointsGenerated")
        local append_txt = ""
        if mult ~= 1 then
            append_txt = POINT_INFO({
                mod = mod,
                mult = mult
            })
        end
        return txt1 .. append_txt
    end)
end

local EARN_MONEY = interp("{lootplot:MONEY_COLOR}Earns $%{moneyGenerated:.1f}", VERB_CTX)
local STEAL_MONEY = interp("{lootplot:BAD_COLOR}Costs {lootplot:MONEY_COLOR}$%{moneyGenerated:.1f}{/lootplot:MONEY_COLOR} to activate!")
local MONEY_INFO = interp("  ({lootplot:POINTS_MOD_COLOR}%{mod}{/lootplot:POINTS_MOD_COLOR} x {lootplot:POINTS_MULT_COLOR}%{mult} mult{/lootplot:POINTS_MULT_COLOR})")

umg.on("lootplot:populateDescription", 30, function(ent, arr)
    local pgen = ent.pointsGenerated
    if pgen and pgen ~= 0 then
        addPointsDescription(ent, arr, pgen)
    end

    local mEarn = ent.moneyGenerated
    if mEarn and mEarn ~= 0 then
        if mEarn > 0 then
            arr:add(funcLocEnt(EARN_MONEY, ent))
        else
            arr:add(funcLocEnt(STEAL_MONEY, ent))
        end
    end
end)



local ACTIVATIONS = interp("Activations: {lootplot:POINTS_COLOR}%{remaining}/%{total}")
local NO_ACTIVATIONS = interp("{lootplot:BAD_COLOR}No Activations: %{remaining}/%{total}")

umg.on("lootplot:populateDescription", 50, function(ent, arr)
    if ent.maxActivations and ent.activationCount then
        if ent.doomCount and (ent.doomCount < ent.maxActivations) then
            -- HACK: Doomcount check here.
            return -- no point in displaying.
        end

        arr:add(function ()
            local remaining = ent.maxActivations - ent.activationCount
            local vars = {
                remaining = remaining,
                total = ent.maxActivations
            }
            local interpolator = remaining > 0 and ACTIVATIONS or NO_ACTIVATIONS
            return interpolator(vars)
        end)
    end
end)




local DOOMED_MULTI = interp("{wavy}{lootplot:DOOMED_COLOR}DOOMED %{doomCount}:{/lootplot:DOOMED_COLOR}{/wavy} {lootplot:DOOMED_LIGHT_COLOR}Destroyed after %{doomCount} activations!")
local DOOMED_1 = interp("{wavy}{lootplot:DOOMED_COLOR}DOOMED %{doomCount}:{/lootplot:DOOMED_COLOR}{/wavy} {lootplot:DOOMED_LIGHT_COLOR}Destroyed when activated!")

umg.on("lootplot:populateDescription", 60, function(ent, arr)
    if ent.doomCount then
        local interpolator = ent.doomCount == 1 and DOOMED_1 or DOOMED_MULTI
        arr:add(funcLocEnt(interpolator, ent))
    end
end)

local EXTRA_LIFE = interp("{wavy}{lootplot:LIFE_COLOR}EXTRA LIVES:{/lootplot:LIFE_COLOR} %{lives}")

umg.on("lootplot:populateDescription", 60, function(ent, arr)
    if ent.lives and ent.lives > 0 then
        arr:add(funcLocEnt(EXTRA_LIFE, ent))
    end
end)
