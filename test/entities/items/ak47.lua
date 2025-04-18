

return umg.defineEntityType("ak47", {
    maxStackSize = 1;
    image="suppressed_gun";
    itemName = "ak47";

    shooter = {
        projectileType = "block",

        speed = 400, -- speed of projectiles
        count = 9, -- num fired

        inaccuracy = 0,

        startDistance = 40,
    },

    itemCooldown = 0.1,
   
    itemHoldType = "recoil",
})
