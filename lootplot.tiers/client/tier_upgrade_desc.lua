


umg.on("lootplot:populateDescription", 70, function(ent, arr)
    if not lp.isItemEntity(ent) then
        return
    end
    if not (ent.tierUpgrade and ent.tierUpgrade.description) then
        return
    end

    local selected = lp.getCurrentSelection()
    local item = selected and selected.item
    if item and item ~= ent and lp.tiers.canUpgrade(ent, item) then
        arr:add("{wavy amp=2}{lootplot:COMBINE_COLOR}==========================")
        arr:add("{lootplot:COMBINE_COLOR}{wavy}UPGRADE:")
        local desc = ent.tierUpgrade.description
        if objects.isCallable(desc) then
            desc = desc(ent)
        end
        assert(type(desc) == "string", "?")
        arr:add("{lootplot:COMBINE_COLOR}  " .. desc)
        arr:add("{wavy amp=2}{lootplot:COMBINE_COLOR}==========================")
    end
end)

