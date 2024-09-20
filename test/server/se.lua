

local ents = server.entities


local uname_to_player = {}


local function make_player(uname)
    local ent = ents.player(20, 10, uname)
    ent.z = 0
    ent.moveX = 0
    ent.moveY = 0
    uname_to_player[uname] = ent
    return ent
end




local function newItem(ctor, stackSize)
    local MAG = 300
    local e = ctor()
    e.stackSize = stackSize or 1
    local dvec = {x=math.random(-MAG, MAG), y=math.random(-MAG, MAG)}
    items.drop(e, dvec)
    return e
end



local dim1 = "overworld"
local dim2 = "other"



if server then

umg.on("@load", function()
    spatial.createDimension(dim2)
    borders.setBorder(dim2, {
        centerX = 0,
        centerY = 0,
        width = 1000,
        height = 10000
    })

    ents.crate(0,-100)
    ents.basic_box(0, 100)

    newItem(ents.ak47)

    for i=1, 5 do
        newItem(ents.musket)
    end
end)

end



-- use playersaves API
umg.on("playersaves:createPlayer", function(uname)
    make_player(uname)
end)


