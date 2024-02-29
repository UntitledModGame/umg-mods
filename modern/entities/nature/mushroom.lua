

local IMGS = {
    "ME_Singles_Camping_16x16_Mushrooms_1",
    "ME_Singles_Camping_16x16_Mushrooms_2",
    "ME_Singles_Camping_16x16_Mushrooms_3"
}


return {
    bobbing = {magnitude = 0.04},

    maxStackSize = 10,

    init = function(ent)
        ent.image = table.random(IMGS)
    end
}

