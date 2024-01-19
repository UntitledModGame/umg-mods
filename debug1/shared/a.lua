


umg.definePacket("debug1:packet1", {
    typelist = {"entity"}
})


local SKIPS = 30


if server then

local e

local func = scheduling.skip(SKIPS, function()
    print("Send!")
    server.broadcast("debug1:packet1", e)
    server.broadcast("debug1:packet1", e)
    server.broadcast("debug1:packet1", e)
end)

umg.on("@load", function()
    local e = server.entities.empty()
    umg.on("@tick", func)
end)


end


if client then

client.on("debug1:packet1", function(e)
    print("RECV: ", e.id)
end)

end
