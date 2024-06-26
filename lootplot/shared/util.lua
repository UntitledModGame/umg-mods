local util = {}

function util.remoteServerCall(name, args, func)
    umg.definePacket(name, {
        typelist = args
    })

    if server then
        server.on(name, func)
    end

    local function call(...)
        assert(client,"?")
        client.send(name, ...)
    end
    return call
end

return util
