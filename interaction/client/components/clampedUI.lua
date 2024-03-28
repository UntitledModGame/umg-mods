


local function getClampedRegion(ent, sceneRegion)
    local region = ent.uiRegion
    return region
        :clampInside(sceneRegion)
end


local clampedUIGroup = umg.group("clampedUI", "uiRegion")

umg.on("@update", function()
    local sceneRegion = ui.getSceneRegion()
    for _, ent in ipairs(clampedUIGroup) do
        if ui.isOpen(ent) then
            ent.uiRegion = getClampedRegion(ent, sceneRegion)
        end
    end
end)
