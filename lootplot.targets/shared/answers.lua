

umg.answer("lootplot.targets:canTarget", function(ent, ppos, targEnt)
    if ent.targetTraits then
        if umg.exists(targEnt) then
            for _, trait in ipairs(ent.targetTraits) do
                if lp.hasTrait(ent, trait) then
                    return true
                end
            end
        end

        return false
    end

    return true
end)

