


local INV1 = "entity"
local INV2 = "entity"

local SLOT1 = "number"
local SLOT2 = "number"

local ITEM = "entity"

local PLAYER = "entity"

local COUNT = "number"



umg.definePacket("items:trySwapItem", {
    typelist = {PLAYER, INV1, SLOT1, INV2, SLOT2}
})



umg.definePacket("items:tryMoveItem", {
    typelist = {PLAYER, INV1, SLOT1, INV2, SLOT2, COUNT}
})


umg.definePacket("items:tryDropItem", {
    typelist = {PLAYER, INV1, SLOT1}
})


umg.definePacket("items:setInventorySlot", {
    typelist = {INV1, SLOT1, ITEM}
})

umg.definePacket("items:clearInventorySlot", {
    typelist = {INV1, SLOT1}
})


