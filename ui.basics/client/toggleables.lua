

local toggleables = {}


local function isToggleable(ent)
    local prop = ent.uiProperties
    return prop and prop.toggleable
end


local function open(ent)
    local scene = ui.basics.getScene()
    scene:addChild(ent.ui)
end


function toggleables.openAllControlled()
    for _, controlEnt in ipairs(control.getControlledEntities()) do
        if controlEnt.ui and isToggleable(controlEnt) then
            open(controlEnt)
        end
    end
end



function toggleables.closeAll()
    local closebuf = objects.Array()
    umg.melt([[
        TODO: ui.basics.getOpenElements should iterate over ui entities instead,
        since elem:getEntity() has been removed
    ]])
    for _, elem in ipairs(ui.basics.getOpenElements()) do
        local ent = elem:getEntity()
        if isToggleable(ent) then
            closebuf:add(ent)
        end
    end
    for _, ent in ipairs(closebuf) do
        ui.basics.close(ent)
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
            if controlEnt.ui and ui.basics.isOpen(controlEnt) then
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
