
local loc = localization.localize


local function defCurse(id, name, etype)
    etype = etype or {}

    etype.image = id
    etype.name = loc(name)

    etype.isCurse = 1
    etype.curseCount = 1

    etype.triggers = etype.triggers or {"PULSE"}
    etype.baseMaxActivations = etype.baseMaxActivations or 4

    etype.canItemFloat = true

    lp.defineItem("lootplot.s0:" .. (id), etype)
end



defCurse("anti_bonus_contract_curse", "Anti Bonus Contract", {
    description = loc("Whilst this curse exists, {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} cannot go higher than -1."),

    onUpdateServer = function(ent)
        if lp.getPointsBonus(ent) > -1 then
            lp.setPointsBonus(ent, -1)
        end
    end
})

