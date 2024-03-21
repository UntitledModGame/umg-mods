

local PINES = {
    "ME_Singles_Camping_16x16_Tree_206",
    "ME_Singles_Camping_16x16_Tree_212",
}


return umg.defineEntityType("pine", {
    swaying = {magnitude = 0.1},

    physics = {
        shape = love.physics.newCircleShape(8),
        type = "static"
    },

    oy = 16,

    initXY = true,
    init = function(ent)
        ent.image = table.random(PINES)
    end
})

