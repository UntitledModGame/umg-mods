

local loc = localization.localize


local function funcLocEnt(txt, ent, ctx)
    --[[
    we need a function to interpolate the variables per frame!
    ]]
    return function()
        return loc(txt, ent, ctx) 
    end
end



umg.on("lootplot:populateDescription", -10, function(ent, arr)
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



local VERB_CTX = {
    context = "Should be translated within a verb context"
}

umg.on("lootplot:populateDescription", function(ent, arr)
    local pgen = ent.pointsGenerated
    if pgen == 0 then
        return
    end

    if pgen > 0 then
        arr:add(funcLocEnt("Generates {pointsGenerated} points!", ent, VERB_CTX))
    else
        arr:add(funcLocEnt("Steals {pointsGenerated} points!", ent, VERB_CTX))
    end
end)


umg.on("lootplot:populateDescription", function(ent, arr)
    local mEarn = ent.moneyGenerated
    if mEarn == 0 then
        return
    end

    if mEarn > 0 then
        arr:add(funcLocEnt("{c r=0.5 g=1 b=0.4}Earns ${moneyGenerated} when activated", ent, VERB_CTX))
    else
        arr:add(funcLocEnt(
            "{c r=1 g=0.2 b=0}{i}Steals {/i}{/c}{c r=1 g=0.87 b=0}${moneyGenerated} when activated", 
            ent, 
            VERB_CTX
        ))
    end
end)

