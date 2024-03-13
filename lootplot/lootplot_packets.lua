

local X,Y = "number", "number"
local ENT = "entity"

umg.definePacket("looplot:setPlotSlot", {
    typelist = {X, Y, ENT}
})
 
umg.definePacket("looplot:clearPlotSlot", {
    typelist = {X, Y}
})


