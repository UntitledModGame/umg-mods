local util = {}

---@param name string
---@param args string[]
---@param func function
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

---@param dx number
---@param dy number
function util.chebyshevDistance(dx, dy)
    return math.max(math.abs(dx), math.abs(dy))
end

return util
