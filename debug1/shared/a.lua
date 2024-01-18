


umg.definePacket("debug1:packet1", {
    typelist = {}
})


local SKIPS = 30


if server then

umg.on("@tick", scheduling.skip(SKIPS, function()
    print("Send!")
    server.broadcast("debug1:packet1")
end))

end


if client then

client.on("debug1:packet1", function()
    print("RECV! :)")
end)

end
