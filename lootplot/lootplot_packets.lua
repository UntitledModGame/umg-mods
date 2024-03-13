

local X,Y = "number", "number"
local ENT = "entity"

umg.definePacket("lootplot:setPlotSlot", {
    typelist = {X, Y, ENT}
})
 
umg.definePacket("lootplot:clearPlotSlot", {
    typelist = {X, Y}
})


