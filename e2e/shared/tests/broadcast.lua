
--[[
    Testing broadcast functionality
]]


umg.definePacket("e2e:an_example_test", {typelist = {"string"}})
umg.definePacket("e2e:tests_send_to_server", {typelist = {"string", "number"}})


zenith.test("e2e:broadcast", function(self)
    local recvd = false

    if client then
        client.on("e2e:an_example_test", function(msg)
            recvd = true
            self:assert(msg == "hi")
        end)
    end

    self:tick()

    if server then
        server.broadcast("e2e:an_example_test", "hi")
    end

    self:tick(2)

    if client then
        self:assert(recvd, "msg not recvd")
    end

    --[[
        testing client --> server events,
        and validation
    ]]
    local aRecv, bRecv

    if server then
        server.on("e2e:tests_send_to_server", function(sender, a, b)
            aRecv, bRecv = a, b
        end)
    end

    self:tick()

    -- test that we aren't receiving packets:
    local str = "all goods"
    if client then
        aRecv, bRecv = str, 2
        client.send("e2e:tests_send_to_server", aRecv, bRecv)
    end

    self:tick(2)
    self:assert(aRecv==str and bRecv==2, "Didn't pick up packet even tho valid")
end)

