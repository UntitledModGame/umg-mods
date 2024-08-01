

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

umg.on("lootplot:populateDescription", 0, function(ent, arr)
    if ent.maxActivations and ent.activationCount then
        arr:add(function ()
            local remaining = ent.maxActivations - ent.activationCount
            local vars = {
                remaining = remaining,
                total = ent.maxActivations
            }
            if remaining > 0 then
                return loc("Activations: {c r=0.2 b=0.3 g=1}%{remaining}/%{total}", vars)
            else
                return loc("{c r=1 b=0.1 g=0.15}No Activations: %{remaining}/%{total}", vars)
            end
        end)
    end
end)


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




local VERB_CTX = {
    context = "Should be translated within a verb context"
}

umg.on("lootplot:populateDescription", 10, function(ent, arr)
    local pgen = ent.pointsGenerated
    if pgen ~= 0 then
        if pgen > 0 then
            arr:add(funcLocEnt("{c r=0.4 g=0.4 b=1}Generates %{pointsGenerated} point(s)", ent, VERB_CTX))
        else
            arr:add(funcLocEnt("{c r=1 g=0 b=0.2}Steals %{pointsGenerated} point(s)!", ent, VERB_CTX))
        end
    end

    local mEarn = ent.moneyGenerated
    if mEarn ~= 0 then
        if mEarn > 0 then
            arr:add(funcLocEnt("{c r=0.5 g=1 b=0.4}Earns $%{moneyGenerated}", ent, VERB_CTX))
        else
            arr:add(funcLocEnt(
                "{c r=1 g=0.2 b=0}Steals {/c}{c r=1 g=0.87 b=0}$%{moneyGenerated}!", 
                ent, 
                VERB_CTX
            ))
        end
    end
end)


umg.on("lootplot:populateDescription", 50, function(ent, arr)
    if ent.doomCount then
        if ent.doomCount == 1 then
            arr:add(funcLocEnt(
                "{c r=0.46 g=0 b=0.6}DOOMED:{/c} {c r=0.7 g=0.3 b=1}Destroyed when activated!", 
                ent
            ))
        else
            arr:add(funcLocEnt(
                "{c r=0.46 g=0 b=0.6}DOOMED:{/c} {c r=0.7 g=0.3 b=1}Destroyed after %{doomCount} activations!", 
                ent
            ))
        end
    end
end)



umg.on("lootplot:populateDescription", 50, function(ent, arr)
    if ent.moneyGenerated and ent.moneyGenerated < 0 then
        arr:add(funcLocEnt(
            "{c r=1 g=1 b=0.4}{i}Requires money to activate.", 
            ent
        ))
    end
end)


umg.on("lootplot:populateDescription", 50, function(ent, arr)
    local t = ent.traits
    if t and #t > 0 then
        arr:add(loc("Traits: "))
        for _, t in ipairs(t) do
            arr:add(" {c r=0.4 g=0.2 b=1}{wavy}" .. t)
        end
        arr:add("")
    end
end)

