

local INDEX = "number"
local ENT = "entity"

umg.definePacket("lootplot:setPlotSlot", {
    typelist = {ENT, INDEX, ENT}
})
 
umg.definePacket("lootplot:clearPlotSlot", {
    typelist = {ENT, INDEX}
})


