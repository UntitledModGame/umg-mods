


umg.definePacket("debug1:packet1", {
    typelist = {"entity"}
})


local SKIPS = 30


if server then

local e

local func = scheduling.skip(SKIPS, function()
    server.broadcast("debug1:packet1", e)
    server.broadcast("debug1:packet1", e)
    server.broadcast("debug1:packet1", e)
end)

umg.on("@load", function()
    e = server.entities.empty()
    e.t = "foo"
    umg.on("@tick", func)
end)


end


if client then

local recvE

client.on("debug1:packet1", function(e)
    assert(e.t == "foo","ay?")
    if not recvE then
        recvE = e
    end
    print("RECV: ", e.id)
    assert(e == recvE,"?")
end)

end



umg.on("@keypressed", function(k)
    if k=="q" then
        error("y")
    end
end)

