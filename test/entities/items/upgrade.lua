

return {
    maxStackSize = 1;
    image="lantern";

    propertyEffect = {
        property = "speed",
        multiplier = 2
    },

    eventEffect = {
        event = "projectiles:projectileShot",
        trigger = function(effectEnt, ownerEnt, ...)
            print("EV EFFECT!")
        end
    },

    itemName = "My upgrade",
    itemDescription = "Gives 2x speed",
    
    spinning = {
        period = 0.8;
        magnitude = 1.2
    };

    itemHoldType = "above",
}

