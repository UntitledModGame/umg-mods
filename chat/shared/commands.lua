

local commands = {}

--[[

Commands exist on BOTH clientside AND serverside.

If a command is declared on clientside, it will work on clientside only.
If a command is declared on serverside, it will work on serverside only.
If declared on both, it will work on both.


]]



local commandToHandler = {--[[
    [commandName] -> handler_object
]]}





local VALID_TYPES = {
    string = true,
    number = true,
    entity = true,
    boolean = true
}

local function getArgsTypechecker(arguments)
    local typeBuffer = objects.Array()
    for _, arg in ipairs(arguments) do
        assert(VALID_TYPES[arg.type], "arg type invalid: " .. tostring(arg.type))
        assert(type(arg.name) == "string", "arg.name needs to be string")
        typeBuffer:add(arg.type)
    end
    return typecheck.check(unpack(typeBuffer))
end



local handleCommandTypecheck = typecheck.assert("string", "table")


function commands.handleCommand(commandName, handler)
    --[[
        {
            handler = function(sender, etype, x, y)
                if not server.entities[etype] then
                return nil, "couldn't find entity"
                end

                server.entities[etype](x,y)
                return true
            end,

            adminLevel = 5, -- minimum level required to execute this command

            args = {
                {type = "string", name = "etype"},
                {type = "number", name = "x"},
                {type = "number", name = "y"}
            },

            description = "this command does stuff"
        }
    ]]
    handleCommandTypecheck(commandName, handler)
    assert(type(handler.handler) == "function", "not given .handler function")
    assert(type(handler.arguments) == "table", "not given .arguments table")
    assert(handler.adminLevel, "not given .adminLevel number")
    handler.typechecker = getArgsTypechecker(handler.arguments)
    handler.commandName = commandName
    commandToHandler[commandName] = handler
end




if server then

server.on("chat:command", function(sender, commandName, ...)
    --[[
        this is for when the player does any of the following:
        /commandName ...
        !commandName ...
        ;commandName ...
        ?commandName ...
        $commandName ...
    ]]
    if type(commandName) ~= "string" then
        -- must check this, coz its a dynamic packet
        return 
    end
    local cmdHandler = commandToHandler[commandName]
    if not cmdHandler then
        chat.privateMessage(sender, "unknown command: " .. commandName)
        return
    end

    local ok, err = cmdHandler.typechecker(...)
    if not ok then
        chat.privateMessage(sender, "/" .. commandName .. ": " .. err)
        return
    end

    local adminLevel = chat.getAdminLevel(sender)
    if cmdHandler.adminLevel > adminLevel then 
        chat.privateMessage(sender, "/" .. commandName .. ": Admin level " .. tostring(handler.adminLevel) .. " required.")
        return
    end

    cmdHandler.handler(sender, ...)
    server.broadcast("chat:command", sender, commandName, ...)
end )

end




if client then

client.on("chat:command", function(sender, commandName, ...)
    local cmdHandler = commandToHandler[commandName]
    if cmdHandler then
        -- there may not be a handler for client.
        cmdHandler.handler(sender, ...)
    end
end)

end




return commands
