
--[[
An example of a zenith test!

To actually run this test, do:

zenith.defineTest({
    test = test1,
    name = "my test 1"
})


and then call:

zenith.runTests()

]]



function test1(self)
    umg.definePacket("zenith:test_a", {
        typelist = "string"
    })

    -- runs code on server
    if server then
        server.broadcast("zenith:test_a", "hi")
    end

    local recvd = false

    -- runs code on client
    if client then
        client.on("zenith:test_a", function(msg)
            recvd = true
            self:assert(msg == "hi")
        end)
    end

    -- waits 2 ticks, on both client AND server.
    self:tick(2)

    -- runs code on client again.
    if client then
        self:assert(recvd, "msg not recvd")
    end
end
