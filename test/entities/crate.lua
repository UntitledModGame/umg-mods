
return {
    image = "crate",
    authorizeInRange = {
        distance = 100,
    };

    init = function(ent, x,y)
        ent.x = x
        ent.y = y
        ent.inventory = items.Inventory({
            size=25, slotSeparation = 10
        })
    end;

    light = {
        size = 240;
        color = {1,1,1}
    };
}

