

umg.answer("lootplot.targets:canTarget", function(ent, ppos, targEnt)
    if ent.targetMatchTrait then
        if umg.exists(targEnt) then
            return lp.hasTrait(ent.targetTraitFilter)
        end
    end
    return true
end)

