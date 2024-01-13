

umg.definePacket("items:trySwapInventoryItem", {
    typelist = {
        --player   inv1       inv2
        "entity", "entity", "entity",
        --slot1     slot2
        "number", "number",
    },
})



umg.definePacket("items:tryMoveInventoryItem", {
    typelist = {
        --player   inv1       inv2
        "entity", "entity", "entity",
        --slot1     slot2    count
        "number", "number", "number"
    },
})


umg.definePacket("items:tryDropInventoryItem", {
    typelist = {
        --player   inv1       slot
        "entity", "entity", "number",
    },
})




