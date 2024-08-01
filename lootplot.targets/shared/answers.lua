

umg.answer("lootplot.targets:canTarget", function(ent, ppos, targEnt)
    if ent.targetTrait then
        return umg.exists(targEnt) and lp.hasTrait(targEnt, ent.targetTrait)
    end

    return true
end)

