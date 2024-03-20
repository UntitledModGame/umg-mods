

--[[


DUAL-FUNCTIONS API:

umg.definePacket("mod:explode", {
    typelist = {"number", "number"}
})

local func = sync.RPC("mod:explode", function(x,y)
    ...
end)




func(ent, 1)
-- If called on server, 
-- will AUTOMATICALLY be dispatched to client.

-- When called on client, 
-- will just be called normally.



]]


local makeDualTc = typecheck.assert("string", "function")

local function RPC(packetName, func)
    makeDualTc(packetName, func)

    local function dualFunc(...)
        if server then
            server.broadcast(packetName, ...)
        end
        func(...)
    end

    if client then
        client.on(packetName, func)
    end

    return dualFunc
end



return RPC

