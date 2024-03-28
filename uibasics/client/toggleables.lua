

local toggleables = {}


local function isToggleable(ent)
    local prop = ent.uiProperties
    return prop and prop.toggleable
end


function toggleables.openAllControlled()
    for _, controlEnt in ipairs(control.getControlledEntities()) do
        if isToggleable(controlEnt) then
            ui.open(controlEnt)
        end
    end
end



function toggleables.closeAll()
    for _, elem in ipairs(ui.getOpenElements()) do
        local ent = elem:getEntity()
        if isToggleable(ent) then
            ui.close(ent)
        end
    end
end




function toggleables.areMostOpen()
    --[[
        The client may be controlling multiple players at once.
        This function checks if the majority of players have open UIs.
    ]]
    local ct = 0
    local tot_ct = 0
    for _, controlEnt in ipairs(control.getControlledEntities()) do
        if sync.isClientControlling(controlEnt) then
            if ui.isElement(controlEnt) and ui.isOpen(controlEnt) then
                tot_ct = tot_ct + 1
                ct = ct + 1
            end
        end
    end

    if tot_ct > 0 then
        return (ct / tot_ct) > 0.5
    end
    return false
end





return toggleables
