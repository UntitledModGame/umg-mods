local util = {}

---@param name string
---@param args string[]
---@param func function
function util.remoteCallToServer(name, args, func)
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


---@param name string
---@param args string[]
---@param func function
function util.remoteBroadcastToClient(name, args, func)
    umg.definePacket(name, {
        typelist = args
    })

    if client then
        client.on(name, func)
    end

    local function call(...)
        assert(server,"?")
        server.broadcast(name, ...)
    end
    return call
end




---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end

return util
