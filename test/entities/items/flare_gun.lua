
return umg.defineEntityType("flare_gun", {
    maxStackSize = 1;
    image="flare_gun";
    itemName = "Flare gun";
    itemDescription = "Shoots a flare to light the way",

    shooter = {
        projectileType = "flare",

        speed = 350, -- speed of projectiles
        count = 1, -- num fired

        inaccuracy = 0,

        startDistance = 50,
    },

    itemCooldown = 0.1,
   
    itemHoldType = "recoil",
})
