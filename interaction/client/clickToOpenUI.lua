


local controlGroup = umg.group("controllable")




local function open(inv)
    local opn = inv.owner.openable
    if opn.openSound then
        sound.playSound(opn.openSound, 1, 1.4, nil, 0, 0.3)
    end
    inv:open()
end



local function areMostPlayerUIsOpen()
    --[[
        The client may be controlling multiple players at once.
        This function checks if the majority of players have open UIs.
    ]]
    local ct = 0
    local tot_ct = 0
    for _, player in ipairs(controlGroup)do
        if sync.isClientControlling(player) then
            if player.ui and ui.isOpen(player) then
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


local function openAllUI()
end


local function closeAllUI()
end




local listener = input.Listener({priority = 2})

function listener:keypressed(key, scancode, isrepeat)
    local inputEnum = self:getKeyboardInputEnum(scancode)
    -- TODO: Allow for controls to be set
    if inputEnum == input.BUTTON_2 then
        if areMostPlayerUIsOpen() then
            -- most player uis are open;
            -- therefore, we want to close.
            closeAllUI()
        else
            openAllUI()
        end
        self:lockKey(scancode)
    end
end

