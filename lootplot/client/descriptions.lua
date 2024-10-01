

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


umg.on("lootplot:populateDescription", -10, function(ent, arr)
    if ent.description then
        local typ = type(ent.description)
        if typ == "string" then
            -- should already be localized:
            arr:add(ent.description)
        elseif typ == "function" then
            arr:add(function()
                -- need to pass ent manually as a closure
                if umg.exists(ent) then
                    return ent.description(ent)
                end
            end)
        end
    end
end)




local IMPLICIT_TRIGGER = "PULSE"

local function hasBasicTrigger(triggers)
    for i, t in ipairs(triggers) do
        if t == IMPLICIT_TRIGGER then
            return true, i
        end
    end
end

local function getTriggerListString(triggers)
    local buf = objects.Array()
    for _,t in ipairs(triggers) do
        if t ~= IMPLICIT_TRIGGER then
            buf:add(t)
        end
    end
    return "[" .. table.concat(buf, ", ") .. "]"
end

local MANUAL_ACTIVATE = loc("{lootplot:BAD_COLOR}{wavy}ONLY ACTIVATES MANUALLY!")
local ALSO_ACTIVATE_TRIGGER = interp("{lootplot:BONUS_COLOR}{wavy}ALSO ACTIVATES WHEN %{trigger}")
local ONLY_ACTIVATE_TRIGGER = interp("{lootplot:BAD_COLOR}{wavy}ONLY ACTIVATES WHEN %{trigger}")

umg.on("lootplot:populateDescription", 10, function(ent, arr)
    local triggers = ent.triggers
    if ent.triggers then
        if #triggers == 0 then
            arr:add(MANUAL_ACTIVATE)
        elseif #triggers == 1 and triggers[1] == IMPLICIT_TRIGGER then
            -- do nothing! It's the default trigger setup.
        else
            local interpolator = hasBasicTrigger(triggers) and ALSO_ACTIVATE_TRIGGER or ONLY_ACTIVATE_TRIGGER
            arr:add(interpolator({trigger = getTriggerListString(triggers)}))
        end
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



umg.on("lootplot:populateDescription", 50, function(ent, arr)
    --[[
    TODO: this is DUMB.
    We should be storing traits some other way.
    ]]
    local t = ent.traits
    if t and #t > 0 then
        arr:add(loc("Traits: "))
        for _, trait in ipairs(t) do
            arr:add(" {c r=0.4 g=0.2 b=1}{wavy}" .. lp.getTraitDisplayName(trait))
        end
        arr:add("")
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
