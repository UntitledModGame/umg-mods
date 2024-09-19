

local loc = localization.localize


local function funcLocEnt(txt, ent, ctx)
    --[[
    we need a function to interpolate the variables per frame!
    ]]
    return function()
        if umg.exists(ent) then
            return loc(txt, ent, ctx) 
        end
        return loc("INVALID ENTITY")
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

umg.on("lootplot:populateDescription", 10, function(ent, arr)
    local triggers = ent.triggers
    if ent.triggers then
        if #triggers == 0 then
            arr:add("{lootplot:BAD_COLOR}{wavy}ONLY ACTIVATES MANUALLY!")
        elseif #triggers == 1 and triggers[1] == IMPLICIT_TRIGGER then
            -- do nothing! It's the default trigger setup.
        else
            local trigStr = getTriggerListString(triggers)
            if hasBasicTrigger(triggers) then
                arr:add("{lootplot:BONUS_COLOR}{wavy}ALSO ACTIVATES WHEN " .. trigStr)
            else
                arr:add("{lootplot:BAD_COLOR}{wavy}ONLY ACTIVATES WHEN " .. trigStr)
            end
        end
    end
end)






local VERB_CTX = {
    context = "Should be translated within a verb context"
}

local function addPointsDescription(ent, arr, pgen)
    arr:add(function()
        if not umg.exists(ent) then
            return ""
        end
        local txt1
        if pgen > 0 then
            txt1 = loc("Points generated: {lootplot:POINTS_COLOR}%{pointsGenerated:.1f}{/lootplot:POINTS_COLOR}", ent, VERB_CTX)
        else
            txt1 = loc("{lootplot:BAD_COLOR}Steals points: {lootplot:POINTS_COLOR}%{pointsGenerated:.1f}{/lootplot:BAD_COLOR} ", ent, VERB_CTX)
        end
        -- todo: this is kinda inefficient. OH WELL :)
        local _, mod, mult = properties.computeProperty(ent, "pointsGenerated")
        local append_txt = ""
        if mult ~= 1 then
            append_txt = loc("  ({lootplot:POINTS_MOD_COLOR}%{mod}{/lootplot:POINTS_MOD_COLOR} x {lootplot:POINTS_MULT_COLOR}%{mult} mult{/lootplot:POINTS_MULT_COLOR})", {
                mod = mod,
                mult = mult
            })
        end
        return txt1 .. append_txt
    end)
end

umg.on("lootplot:populateDescription", 30, function(ent, arr)
    local pgen = ent.pointsGenerated
    if pgen and pgen ~= 0 then
        addPointsDescription(ent, arr, pgen)
    end

    local mEarn = ent.moneyGenerated
    if mEarn and mEarn ~= 0 then
        if mEarn > 0 then
            arr:add(funcLocEnt("{lootplot:MONEY_COLOR}Earns $%{moneyGenerated:.1f}", ent, VERB_CTX))
        else
            arr:add(funcLocEnt(
                "{lootplot:BAD_COLOR}Steals {/lootplot:BAD_COLOR}{lootplot:MONEY_COLOR}$%{moneyGenerated:.1f}!", 
                ent, 
                VERB_CTX
            ))
        end
    end
end)




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
            if remaining > 0 then
                return loc("Activations: {lootplot:POINTS_COLOR}%{remaining}/%{total}", vars)
            else
                return loc("{lootplot:BAD_COLOR}No Activations: %{remaining}/%{total}", vars)
            end
        end)
    end
end)



umg.on("lootplot:populateDescription", 50, function(ent, arr)
    if ent.moneyGenerated and ent.moneyGenerated < 0 then
        arr:add(funcLocEnt(
            "{lootplot:INFO_COLOR}Requires money to activate.", 
            ent
        ))
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
        for _, t in ipairs(t) do
            arr:add(" {c r=0.4 g=0.2 b=1}{wavy}" .. lp.getTraitDisplayName(t))
        end
        arr:add("")
    end
end)


umg.on("lootplot:populateDescription", 60, function(ent, arr)
    if ent.doomCount then
        if ent.doomCount == 1 then
            arr:add(funcLocEnt(
                "{wavy}{lootplot:DOOMED_COLOR}DOOMED %{doomCount}:{/lootplot:DOOMED_COLOR}{/wavy} {lootplot:DOOMED_LIGHT_COLOR}Destroyed when activated!", 
                ent
            ))
        else
            arr:add(funcLocEnt(
                "{wavy}{lootplot:DOOMED_COLOR}DOOMED %{doomCount}:{/lootplot:DOOMED_COLOR}{/wavy} {lootplot:DOOMED_LIGHT_COLOR}Destroyed after %{doomCount} activations!", 
                ent
            ))
        end
    end
end)

umg.on("lootplot:populateDescription", 60, function(ent, arr)
    if ent.lives and ent.lives > 0 then
        arr:add(funcLocEnt(
            "{wavy}{lootplot:LIFE_COLOR}EXTRA LIVES:{/lootplot:LIFE_COLOR} %{lives}",
            ent
        ))
    end
end)
