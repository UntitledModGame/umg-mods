



local commandHandler = {
    adminLevel = 100,
    arguments = {{type = "boolean", name = "mode"}},

    handler = function(sender, isActive)
        if client then
            _G.settings.editing = isActive
        else
            -- TODO: do something on server.
            -- perhaps fudge with settings and whatnot?
            -- eg    /worldeditor settings.xyz foo
        end
    end
}

chat.handleCommand("worldeditor", commandHandler)



