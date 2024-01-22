


-- Server --> client; called when a tick happens
umg.definePacket("zenith:nextTick", {
    typelist = {"number"}
})

-- Client --> server: client-side acknowledges a tick.
umg.definePacket("zenith:acknowledgeTick", {
    typelist = {"number"}
})
--[[

The reason we need these two packets,
Is because sometimes client-side may run code that takes a  
long time to run; (ie. takes longer than one tick.)

As such, the server needs to wait until the client is ready,
using this tick-sync mechanism.

]]

