

require("shared.exports")


local function formatCommand(handler)
    local str = handler.commandName .. "("
    for _, arg in ipairs(handler.arguments) do
        str = str .. arg.name .. ":" .. arg.type .. "  "
    end
    str = str .. ")"
    if handler.description then
        str = str .. "\n   " .. handler.description
    end
    return str
end


--[[

chat.handleCommand("help", {
    arguments = {},
    adminLevel = 0,

    handler = function(sender)
        local adminLevel = permissions.getAdminLevel(sender)
        local commands = chat.getCommands()
        chat.privateMessage(sender, "COMMAND LIST:")
        for _, cmdName in ipairs(commands)do
            if handler.adminLevel <= adminLevel then
                local str = formatCommand(handler)
                chat.privateMessage(sender, str)
            end
        end
    end
})

]]


chat.handleCommand("promote", {
    arguments = {
        {name = "user", type = "string"}, {name = "level", type = "number"}
    },

    adminLevel = 1,

    handler = function(sender, user, level)
        local adminLv = permissions.getAdminLevel(sender)
        local targetAdminLv = permissions.getAdminLevel(user)
        level = math.max(targetAdminLv, level)
        if adminLv > level and adminLv > targetAdminLv then
            permissions.setAdminLevel(user, level)
        end
    end
})




chat.handleCommand("demote", {
    arguments = {
        {name = "user", type = "string"}, {name = "level", type = "number"}
    },

    adminLevel = 1,

    handler = function(sender, user, level)
        local adminLv = permissions.getAdminLevel(sender)
        local targetAdminLv = permissions.getAdminLevel(user)
        level = math.min(targetAdminLv, level)
        if adminLv > level and adminLv > targetAdminLv then
            permissions.setAdminLevel(user, level)
        end
    end
})


