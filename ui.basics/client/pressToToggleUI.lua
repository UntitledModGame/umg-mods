
local toggleables = require("client.toggleables")

require("client.interactionControls")



local listener = input.InputListener()
input.add(listener, 2)

local INTERACT = "ui.basics:TOGGLE"

listener:onPressed(INTERACT, function(self)
    if toggleables.areMostOpen() then
        -- most player uis are open;
        -- therefore, we want to close.
        toggleables.closeAll()
    else
        toggleables.openAllControlled()
    end
    self:claim(INTERACT)
end)

