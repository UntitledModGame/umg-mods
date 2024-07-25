

local loc = localization.localize


umg.on("lootplot:populateDescription", -10, function(ent, arr)
    if ent.maxActivations then
        arr:add(loc(
            "Maximum activations: {c r=1 b=0 g=0}%{maxActivations}",
            ent
        ))
        
        if ent.activationCount then
            local remaining = ent.maxActivations - ent.activationCount
            if remaining <= 0 then
                arr:add(loc("{i}{c r=1 b=0 g=0}No activations remaining!"))
            else
                arr:add(loc(
                    "Activations remaining: {c r=1 b=0.5 g=0.4}%{remaining}", {
                        remaining = remaining
                    }
                ))
            end
        end
        arr:add("")--newline
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
        arr:add(loc("Generates {pointsGenerated} points!", ent, VERB_CTX))
    else
        arr:add(loc("Steals {pointsGenerated} points!", ent, VERB_CTX))
    end
end)


umg.on("lootplot:populateDescription", function(ent, arr)
    local mEarn = ent.moneyGenerated
    if mEarn == 0 then
        return
    end

    if mEarn > 0 then
        arr:add(loc("{c }Earns ${moneyGenerated} when activated", ent, VERB_CTX))
    else
        arr:add(loc(
            "{c r=1 g=0 b=0}{i}Steals {/i}{/c}{c r=1 g=0.87 b=0}${moneyGenerated} when activated", 
            ent, 
            VERB_CTX
        ))
    end
end)

