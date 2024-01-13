
--[[
    Testing broadcast functionality
]]


umg.definePacket("umg_e2e_tests:packet1", {
    typelist={}
})



return function()
    local recvd = false

    if client then
        client.on("an_example_test", function(msg)
            recvd = true
            zenith.assert(msg == "hi", "msg not hi")
        end)
    end

    zenith.tick()

    if server then
        server.broadcast("an_example_test", "hi")
    end

    zenith.tick(2)

    if client then
        zenith.assert(recvd, "msg not recvd")
    end



    --[[
        testing client --> server events,
        and validation
    ]]
    local aRecv, bRecv

    if server then
        server.on("umg_e2e_tests:send_to_server", function(sender, a, b)
            aRecv, bRecv = a, b
        end)
    end

    zenith.tick()

    -- test that we aren't receiving packets:
    local str = "all goods"
    if client then
        aRecv, bRecv = str, 2
        client.send("umg_e2e_tests:send_to_server", aRecv, bRecv)
    end
    zenith.tick(2)
    zenith.assert(aRecv==str and bRecv==2, "Didn't pick up packet even tho valid")
    zenith.tick()
end

