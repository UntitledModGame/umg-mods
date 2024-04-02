
require("lootplot_types")


local G = {}




G.posTc = typecheck.assert("ppos")



local rpcTc = typecheck.assert("string", "table", "function")
function G.RPC(packetName, args, func)
    rpcTc(packetName, args, func)
    umg.definePacket(packetName, {
        typelist = args
    })
    
    local tc = typecheck.assert(unpack(args))
    local function rpcFunc(...)
        tc(...)
        if server then
            server.broadcast(packetName, ...)
        end
        func(...)
    end

    if client then
        client.on(packetName, func)
    end
    return rpcFunc
end


for k, v in pairs(G) do
    _G[k] = v
end


return G