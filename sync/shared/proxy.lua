
--[[

Maps local server events automatically to the client.

For example, if umg.call("hello", 1, 2) is called on the server,
then umg.call("hello", 1, 3) will be called automatically on the client.


]]

local proxiedEvents = {}



local function proxyEventToClient(eventName)
    if type(eventName) ~= "string" then
        umg.melt("Expected string as first argument")
    end
    if not eventName then
        umg.melt("Unknown event: " .. tostring(eventName))
    end
    if proxiedEvents[eventName] then
        umg.melt("This event is already being proxied: " .. eventName)
    end

    -- TODO: this is a bit shit and hacky
    local packetName = "sync:PROXY_" .. eventName

    umg.definePacket(packetName, {
        dynamic = true
    })

    if server then
        umg.on(eventName, function(...)
            server.broadcast(packetName, ...)
        end)
    elseif client then
        client.on(packetName, function(...)
            umg.rawcall(eventName, ...) 
        end)
    end
end


return proxyEventToClient
