

--[[


DUAL-FUNCTIONS API:

local func = sync.makeDualFunction("mod:name", myFunc, {
    typelist = {"entity", "number"}
})



func(ent, 1)
-- If called on server, 
-- will AUTOMATICALLY be dispatched to client.

-- When called on client, 
-- will just be called normally.



]]


local DUMMY = function() end




local makeDualTc = typecheck.assert("string", "function", "table?")

local function makeDual(name, func, opt)
    makeDualTc(name, func, opt)
    opt = opt or {}

    local packet = "sync:dualfunc_"
    if opt.typelist then
        umg.definePacket(packet, {
            typelist = opt.typelist
        })
    else
        umg.definePacket(packet, {
            dynamic = true
        })
    end

    local tc = DUMMY
    if opt.typelist then
        tc = typecheck.assert(unpack(opt.typelist))
    end

    local function dualFunc(...)
        tc(...)
        if server then
            server.broadcast(packet, ...)
        end
        func(...)
    end

    if client then
        client.on(packet, func)
    end

    return dualFunc
end



return makeDual

