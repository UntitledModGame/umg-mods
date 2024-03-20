


return umg.defineEntityType("musket", {
    maxStackSize = 1;

    image="musket";

    itemName = "musket";
    itemDescription = "I am a cool-cool musket.",

    shooter = {
        projectileType = "bullet",

        speed = 400, -- speed of projectiles
        count = 5, -- num fired

        inaccuracy = 0.1,

        startDistance = 20,
    },

    itemCooldown = 1,
   
    itemHoldType = "recoil",
})

