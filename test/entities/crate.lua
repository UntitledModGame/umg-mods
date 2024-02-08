
return {
    image = "crate",
    openable = {
        distance = 100,
        public = true
    };

    init = function(ent, x,y)
        ent.x = x
        ent.y = y
        ent.inventory = items.Inventory({
            size=25, slotSeparation = 10
        })
    end;

    inventorySlots = {
        {false,false,false,false,true},
        {false,false,false,false,true},
        {true, true, true, true, true},
        {true, true, true, true, true},
        {true, true, true, true, true}
    },

    light = {
        size = 240;
        color = {1,1,1}
    };
}

