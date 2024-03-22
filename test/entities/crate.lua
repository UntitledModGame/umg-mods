
return umg.defineEntityType("crate", {
    image = "crate",
    authorizeInRange = {
        distance = 100,
    };

    init = function(ent, x,y)
        ent.x = x
        ent.y = y
        ent.inventory = items.Inventory({
            entity = ent,
            size=25
        })
    end;

    light = {
        size = 240;
        color = {1,1,1}
    };
})

