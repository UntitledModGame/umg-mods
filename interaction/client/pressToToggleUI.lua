


local listener = input.Listener({priority = 2})

function listener:keypressed(key, scancode, isrepeat)
    local inputEnum = self:getKeyboardInputEnum(scancode)
    -- TODO: Allow for controls to be set.
    -- We should use a custom-control here

    if inputEnum == input.BUTTON_2 then
        if areMostPlayerUIsOpen() then
            -- most player uis are open;
            -- therefore, we want to close.
            closeAllToggleUI()
        else
            openAllPlayerUI()
        end
        self:lockKey(scancode)
    end
end

