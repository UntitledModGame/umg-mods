

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
    local MAG = 100
    local e = ctor()
    e.stackSize = stackSize or 1
    local dvec = {x=math.random(-MAG, MAG), y=math.random(-MAG, MAG)}
    items.drop(e, dvec)
    return e
end



local dim1 = "overworld"
local dim2 = "other"



umg.on("@createWorld", function()
    spatial.createDimension(dim2)
    borders.setBorder(dim2, {
        centerX = 0,
        centerY = 0,
        width = 1000,
        height = 10000
    })

    local e = server.entities.test(0,0)
    e.image = "spot_block"

    for i=1, 800 do
        local MAG = 1000
        ents.pine(1000 + math.random(-MAG, MAG), math.random(-MAG, MAG))
    end

    ents.crate(0,-100)
    ents.crafting_table(-100, 100)
    ents.crate_button(0, 100)

    newItem(ents.ak47)

    newItem(ents.musket)
end)




umg.on("@tick", function()
    local hostClId = server.getHostClient()
    local lis = control.getControlledEntities(hostClId)
    local p = lis[1]
    if p then
        -- DEBUG:
        -- print(p.x, p.y)
    end
end)



if server.isWorldPersistent() then
    -- use playersaves API
    umg.on("playersaves:createPlayer", function(uname)
        make_player(uname)
    end)
else
    -- just spawn a temp player
    umg.on("@playerJoin", function(uname)
        make_player(uname)
    end)
end


