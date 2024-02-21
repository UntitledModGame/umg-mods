
function openAllPlayerUI()
    for _, player in ipairs(control.getControlledEntities()) do
        if player.ui then
            ui.open(player)
        end
    end
end


return openAllPlayerUI
