
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



local function test1()
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
            zenith.assert(msg == "hi", "msg not hi")
        end)
    end

    -- waits 2 ticks, on both client AND server.
    zenith.tick(2)

    -- runs code on client again.
    if client then
        zenith.assert(recvd, "msg not recvd")
    end
end
